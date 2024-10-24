//https://github.com/aptos-labs/move-by-examples/blob/main/advanced-todo-list/aptos/move/sources/advanced_todo_list.move

module publisher::advanced_list {
  use std::bcs;
  use std::debug::print;
  use std::signer;
  use std::vector;
  use std::string::{utf8, String};
  use aptos_std::string_utils::{format1, format2};
  use aptos_framework::object;

  /// Item list does not exist
  const E_LIST_DOSE_NOT_EXIST: u64 = 1;
  /// Item does not exist
  const E_ITEM_DOSE_NOT_EXIST: u64 = 2;
  /// Item is already completed
  const E_ITEM_ALREADY_COMPLETED: u64 = 3;

  struct Settings has key {
    counter: u64
  }

  struct List has key {
    owner: address,
    items: vector<Item>
  }

  struct Item has store, drop, copy {
    content: String,
    completed: bool
  }

  // only called once when this module is published. init_module is optional, we can have an entry function to replace this
  fun init_module(_module_publisher: &signer) {
    // nothing to do here
  }

  //---------------==  Write functions
  public entry fun init_list(signr: &signer) acquires Settings {
    let sender = signer::address_of(signr);
    let counter =
      if (exists<Settings>(sender)) {
        let settings = borrow_global<Settings>(sender);
        settings.counter
      } else {
        let settings = Settings { counter: 0 };
        // store the Settings resource directly under the signr
        move_to(signr, settings);
        0
      };
    // maker a new object to hold the item list, use the contract_addr_counter as seed
    let obj = object::create_named_object(signr, make_seed(counter));
    let obj_signer = object::generate_signer(&obj);
    let list = List { owner: sender, items: vector::empty() };
    // write function to store the List in the new object
    move_to(&obj_signer, list);
    // increment the counter
    let settings = borrow_global_mut<Settings>(sender);
    settings.counter = settings.counter + 1;
  }

  public entry fun add_item(
    signr: &signer, list_idx: u64, content: String
  ) acquires List {
    let sender = signer::address_of(signr);
    let obj_addr = object::create_object_address(&sender, make_seed(list_idx));
    assert_list_obj_exists(obj_addr);
    let list = borrow_global_mut<List>(obj_addr);
    let new_item = Item { content, completed: false };
    vector::push_back(&mut list.items, new_item);
  }

  public entry fun complete_item(
    signr: &signer, list_idx: u64, item_idx: u64
  ) acquires List {
    let sender = signer::address_of(signr);
    let obj_addr = object::create_object_address(&sender, make_seed(list_idx));
    assert_list_obj_exists(obj_addr);
    let list = borrow_global_mut<List>(obj_addr);
    assert_item_idx_valid(list, item_idx);
    let item = vector::borrow_mut(&mut list.items, item_idx);
    assert!(item.completed == false, E_ITEM_ALREADY_COMPLETED);
    item.completed = true;
  }

  //---------------== Read Functions
  // Get how many item lists the sender has, return 0 if the sender has none.
  #[view]
  public fun get_list_counter(sender: address): u64 acquires Settings {
    if (exists<Settings>(sender)) {
      let settings = borrow_global<Settings>(sender);
      settings.counter
    } else { 0 }
  }

  #[view]
  public fun get_obj_addr(sender: address, list_idx: u64): address {
    object::create_object_address(&sender, make_seed(list_idx))
  }

  #[view]
  public fun has_list(sender: address, list_idx: u64): bool {
    let obj_addr = get_obj_addr(sender, list_idx);
    exists<List>(obj_addr)
  }

  #[view]
  public fun get_list(sender: address, list_idx: u64): (address, u64) acquires List {
    let obj_addr = get_obj_addr(sender, list_idx);
    assert_list_obj_exists(obj_addr);
    let list = borrow_global<List>(obj_addr);
    (list.owner, vector::length(&list.items))
  }

  #[view]
  public fun get_list_by_obj_addr(obj_addr: address): (address, u64) acquires List {
    let list = borrow_global<List>(obj_addr);
    (list.owner, vector::length(&list.items))
  }

  #[view]
  public fun get_item(sender: address, list_idx: u64, item_idx: u64): (String, bool) acquires List {
    let obj_addr = get_obj_addr(sender, list_idx);

    assert_list_obj_exists(obj_addr);

    let list = borrow_global<List>(obj_addr);

    assert_item_idx_valid(list, item_idx);
    //assert!(item_idx < vector::length(&list.items), E_ITEM_DOSE_NOT_EXIST);

    let item = vector::borrow(&list.items, item_idx);
    (item.content, item.completed)
  }

  //---------------== Helper Functions
  fun assert_list_obj_exists(obj_addr: address) {
    assert!(exists<List>(obj_addr), E_LIST_DOSE_NOT_EXIST);
  }

  fun assert_item_idx_valid(list: &List, item_idx: u64) {
    assert!(
      item_idx < vector::length(&list.items),
      E_ITEM_DOSE_NOT_EXIST
    );
  }

  fun get_obj(sender: address, list_idx: u64): object::Object<List> {
    let obj_addr = get_obj_addr(sender, list_idx);
    object::address_to_object(obj_addr)
  }

  fun make_seed(counter: u64): vector<u8> {
    // The seed must be unique per item list maker
    //We add contract address as part of the seed so seed from 2 item list contract for same user would be different
    bcs::to_bytes(&format2(&b"{}_{}", @publisher, counter))
  }

  // --------------- Unit Tests
  #[test_only]
  use aptos_framework::account;

  #[test(signr = @0x01)]
  public entry fun list_end_to_end(signr: signer) acquires List, Settings {
    let sender = signer::address_of(&signr);
    let list_idx = get_list_counter(sender);
    assert!(list_idx == 0, 1);
    account::create_account_for_test(sender);
    assert!(!has_list(sender, list_idx), 2);
    init_list(&signr);
    assert!(get_list_counter(sender) == 1, 3);
    assert!(has_list(sender, list_idx), 4);

    add_item(&signr, list_idx, utf8(b"New Item"));
    let (list_owner, list_length) = get_list(sender, list_idx);
    print(&format1(&b"list_owner: {}", list_owner));
    print(&format1(&b"list_length: {}", list_length));
    assert!(list_owner == sender, 5);
    assert!(list_length == 1, 6);

    let (content, completed) = get_item(sender, list_idx, 0);
    print(&format1(&b"content: {}", content));
    print(&format1(&b"completed: {}", completed));
    assert!(content == utf8(b"New Item"), 8);
    assert!(!completed, 7);

    complete_item(&signr, list_idx, 0);
    let (_content, completed) = get_item(sender, list_idx, 0);
    print(&format1(&b"completed: {}", completed));
    assert!(completed, 9);
  }

  #[test(signr = @0x01)]
  public entry fun list_end_to_end_2_lists(signr: signer) acquires List, Settings {
    let sender = signer::address_of(&signr);
    init_list(&signr);
    let list1_idx = get_list_counter(sender) - 1;
    print(&format1(&b"list1_idx: {}", list1_idx));

    init_list(&signr);
    let list2_idx = get_list_counter(sender) - 1;
    print(&format1(&b"list2_idx: {}", list2_idx));

    add_item(&signr, list1_idx, utf8(b"New Item"));
    let (list_owner, list_length) = get_list(sender, list1_idx);
    assert!(list_owner == sender, 1);
    assert!(list_length == 1, 2);

    let (content, completed) = get_item(sender, list1_idx, 0);
    assert!(!completed, 3);
    assert!(content == utf8(b"New Item"), 4);

    complete_item(&signr, list1_idx, 0);
    let (_content, completed) = get_item(sender, list1_idx, 0);
    assert!(completed, 5);

    add_item(&signr, list2_idx, utf8(b"New Item"));
    let (list_owner, list_length) = get_list(sender, list2_idx);
    assert!(list_owner == sender, 6);
    assert!(list_length == 1, 7);

    let (content, completed) = get_item(sender, list2_idx, 0);
    assert!(!completed, 8);
    assert!(content == utf8(b"New Item"), 9);

    complete_item(&signr, list2_idx, 0);
    let (_content, completed) = get_item(sender, list2_idx, 0);
    assert!(completed, 10);
  }

  #[test(signr = @0x01)]
  #[expected_failure(abort_code = E_LIST_DOSE_NOT_EXIST, location = Self)]
  public entry fun list_does_not_exist(signr: signer) acquires List, Settings {
    let sender = signer::address_of(&signr);
    account::create_account_for_test(sender);
    let list_idx = get_list_counter(sender);
    // account cannot make item in list that does not exist
    add_item(&signr, list_idx, utf8(b"New Item"));
  }

  #[test(signr = @0x01)]
  #[expected_failure(abort_code = E_ITEM_DOSE_NOT_EXIST, location = Self)]
  public entry fun list_item_does_not_exist(signr: signer) acquires List, Settings {
    let sender = signer::address_of(&signr);
    account::create_account_for_test(sender);
    let list_idx = get_list_counter(sender);
    init_list(&signr);
    // can not complete item that does not exist
    complete_item(&signr, list_idx, 1);
  }

  #[test(signr = @0x01)]
  #[expected_failure(abort_code = E_ITEM_ALREADY_COMPLETED, location = Self)]
  public entry fun list_item_already_completed(signr: signer) acquires List, Settings {
    let sender = signer::address_of(&signr);
    account::create_account_for_test(sender);
    let list_idx = get_list_counter(sender);
    init_list(&signr);
    add_item(&signr, list_idx, utf8(b"New Item"));
    complete_item(&signr, list_idx, 0);
    // can not complete item that is already completed
    complete_item(&signr, list_idx, 0);
  }
}
