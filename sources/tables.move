module publisher::table_demo {
  use aptos_framework::table;
  use std::signer;
  use std::string::String;

  const E_SELLER_NOTFOUND: u64 = 0;

  struct Property has store, copy, drop {
    beds: u16,
    baths: u16,
    sqm: u16,
    location: String,
    price: u64,
    available: bool
  }

  struct SellerObj has key {
    tbl: table::Table<u64, Property>,
    prop_cindex: u64
  }

  fun register_seller(signr: &signer) {
    let seller_obj = SellerObj { tbl: table::new(), prop_cindex: 0 };
    move_to(signr, seller_obj);
  }

  fun list_property(signr: &signer, property: Property) acquires SellerObj {
    let sender = signer::address_of(signr);
    assert!(exists<SellerObj>(sender), E_SELLER_NOTFOUND);
    let seller_obj = borrow_global_mut<SellerObj>(sender);
    let prop_cindex = seller_obj.prop_cindex + 1;
    table::upsert(&mut seller_obj.tbl, prop_cindex, property);
    seller_obj.prop_cindex = prop_cindex
  }

  fun read_listing(signr: signer, prop_cindex: u64): (u16, u16, u16, String, u64, bool) acquires SellerObj {
    let sender = signer::address_of(&signr);
    assert!(exists<SellerObj>(sender), E_SELLER_NOTFOUND);
    let seller_obj = borrow_global<SellerObj>(sender);
    let tbl = table::borrow(&seller_obj.tbl, prop_cindex);
    (tbl.beds, tbl.baths, tbl.sqm, tbl.location, tbl.price, tbl.available)
  }

  #[test_only]
  use std::debug::print;
  #[test_only]
  use std::string::utf8;

  #[test(seller1 = @0x123, seller2 = @0x144)]
  fun test_function(seller1: signer, seller2: signer) acquires SellerObj {
    register_seller(&seller1);

    let property = Property {
      beds: 2,
      baths: 2,
      sqm: 110,
      location: utf8(b"Santa Marta, Colombia"),
      price: 120000,
      available: true
    };
    list_property(&seller1, property);
    let (_, _, _, location, _, _) = read_listing(seller1, 1);
    print(&location);

    register_seller(&seller2);
    let property = Property {
      beds: 3,
      baths: 2,
      sqm: 150,
      location: utf8(b"Dubai, UAE"),
      price: 300000,
      available: false
    };
    list_property(&seller2, property);
    let (_, _, _, location, _, _) = read_listing(seller2, 1);
    print(&location);
  }
}
