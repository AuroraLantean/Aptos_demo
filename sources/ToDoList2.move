//https://github.com/aptos-labs/move-by-examples/blob/main/advanced-todo-list/aptos/move/sources/advanced_todo_list.move

module publisher::advanced_list {
    use std::bcs;
    use std::debug::print;
    use std::signer;
    use std::vector;
    use std::string::{utf8, String};
    use aptos_std::string_utils;
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
    public entry fun init_list(signer1: &signer) acquires Settings {
        let sender = signer::address_of(signer1);
        let counter =
            if (exists<Settings>(sender)) {
                let settings = borrow_global<Settings>(sender);
                settings.counter
            } else {
                let settings = Settings { counter: 0 };
                // store the Settings resource directly under the signer1
                move_to(signer1, settings);
                0
            };
        // create a new object to hold the item list, use the contract_addr_counter as seed
        let obj = object::create_named_object(
            signer1, make_seed(counter)
        );
        let obj_signer = object::generate_signer(&obj);
        let list = List { owner: sender, items: vector::empty() };
        // store the List resource under the newly created object
        move_to(&obj_signer, list);
        // increment the counter
        let settings = borrow_global_mut<Settings>(sender);
        settings.counter = settings.counter + 1;
    }

    public entry fun add_item(
        signer1: &signer, list_idx: u64, content: String
    ) acquires List {
        let sender = signer::address_of(signer1);
        let obj_addr = object::create_object_address(
            &sender, make_seed(list_idx)
        );
        assert_user_has_list(obj_addr);
        let list = borrow_global_mut<List>(obj_addr);
        let new_item = Item { content, completed: false };
        vector::push_back(&mut list.items, new_item);
    }

    public entry fun complete_item(
        signer1: &signer, list_idx: u64, item_idx: u64
    ) acquires List {
        let sender = signer::address_of(signer1);
        let obj_addr = object::create_object_address(
            &sender, make_seed(list_idx)
        );
        assert_user_has_list(obj_addr);
        let list = borrow_global_mut<List>(obj_addr);
        assert_item_id_valid(list, item_idx);
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
        assert_user_has_list(obj_addr);
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

        assert_user_has_list(obj_addr);

        let list = borrow_global<List>(obj_addr);

        assert!(item_idx < vector::length(&list.items), E_ITEM_DOSE_NOT_EXIST);

        let item = vector::borrow(&list.items, item_idx);
        (item.content, item.completed)
    }

    //---------------== Helper Functions
    fun assert_user_has_list(user_addr: address) {
        assert!(
            exists<List>(user_addr),
            E_LIST_DOSE_NOT_EXIST
        );
    }

    fun assert_item_id_valid(list: &List, item_id: u64) {
        assert!(
            item_id < vector::length(&list.items),
            E_ITEM_DOSE_NOT_EXIST
        );
    }

    fun get_obj(sender: address, list_idx: u64): object::Object<List> {
        let addr = get_obj_addr(sender, list_idx);
        object::address_to_object(addr)
    }

    fun make_seed(counter: u64): vector<u8> {
        // The seed must be unique per item list creator
        //Wwe add contract address as part of the seed so seed from 2 item list contract for same user would be different
        bcs::to_bytes(&string_utils::format2(&b"{}_{}", @publisher, counter))
    }

    // --------------- Unit Tests

    #[test_only]
    use std::string;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_std::debug;

    #[test(admin = @0x100)]
    public entry fun test_end_to_end(admin: signer) acquires List, Settings {
        let admin_addr = signer::address_of(&admin);
        let list_idx = get_list_counter(admin_addr);
        assert!(list_idx == 0, 1);
        account::create_account_for_test(admin_addr);
        assert!(!has_list(admin_addr, list_idx), 2);
        init_list(&admin);
        assert!(get_list_counter(admin_addr) == 1, 3);
        assert!(has_list(admin_addr, list_idx), 4);

        add_item(&admin, list_idx, string::utf8(b"New Item"));
        let (list_owner, list_length) = get_list(admin_addr, list_idx);
        debug::print(&string_utils::format1(&b"list_owner: {}", list_owner));
        debug::print(&string_utils::format1(&b"list_length: {}", list_length));
        assert!(list_owner == admin_addr, 5);
        assert!(list_length == 1, 6);

        let (content, completed) = get_item(admin_addr, list_idx, 0);
        debug::print(&string_utils::format1(&b"content: {}", content));
        debug::print(&string_utils::format1(&b"completed: {}", completed));
        assert!(!completed, 7);
        assert!(content == string::utf8(b"New Item"), 8);

        complete_item(&admin, list_idx, 0);
        let (_content, completed) = get_item(admin_addr, list_idx, 0);
        debug::print(&string_utils::format1(&b"completed: {}", completed));
        assert!(completed, 9);
    }

    #[test(admin = @0x100)]
    public entry fun test_end_to_end_2_lists(admin: signer) acquires List, Settings {
        let admin_addr = signer::address_of(&admin);
        init_list(&admin);
        let list1_idx = get_list_counter(admin_addr) - 1;
        init_list(&admin);
        let list2_idx = get_list_counter(admin_addr) - 1;

        add_item(&admin, list1_idx, string::utf8(b"New Item"));
        let (list_owner, list_length) = get_list(admin_addr, list1_idx);
        assert!(list_owner == admin_addr, 1);
        assert!(list_length == 1, 2);

        let (content, completed) = get_item(admin_addr, list1_idx, 0);
        assert!(!completed, 3);
        assert!(content == string::utf8(b"New Item"), 4);

        complete_item(&admin, list1_idx, 0);
        let (_content, completed) = get_item(admin_addr, list1_idx, 0);
        assert!(completed, 5);

        add_item(&admin, list2_idx, string::utf8(b"New Item"));
        let (list_owner, list_length) = get_list(admin_addr, list2_idx);
        assert!(list_owner == admin_addr, 6);
        assert!(list_length == 1, 7);

        let (content, completed) = get_item(admin_addr, list2_idx, 0);
        assert!(!completed, 8);
        assert!(content == string::utf8(b"New Item"), 9);

        complete_item(&admin, list2_idx, 0);
        let (_content, completed) = get_item(admin_addr, list2_idx, 0);
        assert!(completed, 10);
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_LIST_DOSE_NOT_EXIST, location = Self)]
    public entry fun test_list_does_not_exist(admin: signer) acquires List, Settings {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        let list_idx = get_list_counter(admin_addr);
        // account cannot create item on a item list (that does not exist
        add_item(&admin, list_idx, string::utf8(b"New Item"));
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_ITEM_DOSE_NOT_EXIST, location = Self)]
    public entry fun test_item_does_not_exist(admin: signer) acquires List, Settings {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        let list_idx = get_list_counter(admin_addr);
        init_list(&admin);
        // can not complete item that does not exist
        complete_item(&admin, list_idx, 1);
    }

    #[test(admin = @0x100)]
    #[expected_failure(abort_code = E_ITEM_ALREADY_COMPLETED, location = Self)]
    public entry fun test_item_already_completed(admin: signer) acquires List, Settings {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        let list_idx = get_list_counter(admin_addr);
        init_list(&admin);
        add_item(&admin, list_idx, string::utf8(b"New Item"));
        complete_item(&admin, list_idx, 0);
        // can not complete item that is already completed
        complete_item(&admin, list_idx, 0);
    }
}
