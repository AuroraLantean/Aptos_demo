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

	//Simple User Object stored at user
  struct User has key {
    balc: u64,
    mesg: String
  }

  #[event]
  struct MessageUpdated has drop, store {
    account: address,
    from_message: String,
    to_message: String
  }

  public entry fun initupdate_user(
    signr: &signer, number: u64, message: String
  ) acquires User {
    let sender = signer::address_of(signr);
    if (!exists<User>(sender)) {
      move_to(signr, User { balc: number, mesg: message });
    } else {
      let user = borrow_global_mut<User>(sender);
      event::emit(
        MessageUpdated {
          account: sender,
          from_message: user.mesg,
          to_message: copy message
        }
      );
      user.balc = number;
      user.mesg = message;
    }
  }

  #[view]
  public fun get_user(addr: address): (u64, String) acquires User {
    assert!(exists<User>(addr), DNOT_EXIST);
    let user = borrow_global<User>(addr);
    (user.balc, user.mesg)
  }

  public entry fun remove_user(signr: &signer): u64 acquires User {
    let user = move_from<User>(signer::address_of(signr));
    let User { balc, mesg } = user;
    balc
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
  public entry fun test_user_obj(signr: signer) acquires User {
    print(&utf8(b"test_user_obj..."));

    let addr = signer::address_of(&signr);
    aptos_framework::account::create_account_for_test(addr);
    let balc = 100;
    let mesg = utf8(b"Hello Aptos!");
    initupdate_user(&signr, balc, mesg);

    let (balc1, mesg1) = get_user(addr);
    print(&utf8(b"message_got"));
    //print(&out.balc);    print(&out.mesg);
    assert!(balc1 == balc, 1);
    assert!(mesg1 == mesg, 1);
  }
}
