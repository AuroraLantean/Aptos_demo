module publisher::counter {
  use std::signer;
  use std::debug::print;
  use std::string::{utf8, String};
  //use std::error;
  use std::timestamp;
  use aptos_framework::event;

  const ADDR1: address = @publisher;
  const DNOT_EXIST: u64 = 100;
  const ENO_MESSAGE: u64 = 0;

  struct Holder has key {
    count: u64,
    mesg: String
  }

  #[event]
  struct MessageChange has drop, store {
    account: address,
    from_message: String,
    to_message: String
  }

  public entry fun set_message(signr: &signer, message: String) acquires Holder {
    let sender = signer::address_of(signr);
    if (!exists<Holder>(sender)) {
      move_to(signr, Holder { count: 0, mesg: message });
    } else {
      let holder = borrow_global_mut<Holder>(sender);
      event::emit(
        MessageChange {
          account: sender,
          from_message: holder.mesg,
          to_message: copy message
        }
      );
      holder.mesg = message;
    }
  }

  #[view]
  public fun get_count(addr: address): u64 acquires Holder {
    assert!(exists<Holder>(addr), DNOT_EXIST);
    borrow_global<Holder>(addr).count
  }

  #[view]
  public fun get_message(addr: address): String acquires Holder {
    assert!(exists<Holder>(addr), DNOT_EXIST);
    borrow_global<Holder>(addr).mesg
  }

  public entry fun increase(signr: &signer) acquires Holder {
    let sender = signer::address_of(signr);
    if (!exists<Holder>(sender)) {
      move_to(signr, Holder { count: 0, mesg: utf8(b"initial") });
    } else {
      let holder = borrow_global_mut<Holder>(sender);
      holder.count = holder.count + 1;
      holder.mesg = utf8(b"one");
    }
  }

  public entry fun time() {
    let t1 = timestamp::now_microseconds();
    print(&utf8(b"microseconds"));
    print(&t1);

    let t2 = timestamp::now_seconds();
    print(&utf8(b"seconds"));
    print(&t2);
  }

  #[test(signr = @0x1)]
  public entry fun sender_can_set_message(signr: signer) acquires Holder {
    print(&utf8(b"sender_can_set_message..."));

    let addr = signer::address_of(&signr);
    aptos_framework::account::create_account_for_test(addr);
    set_message(&signr, utf8(b"Hello Aptos!"));

    let message_got = get_message(addr) == utf8(b"Hello Aptos!");
    print(&utf8(b"message_got"));
    print(&message_got);
    assert!(message_got, ENO_MESSAGE);
  }
}
