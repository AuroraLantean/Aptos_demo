module publisher::reserve_vault {
    use std::string::{String, utf8};
    use std::simple_map::{SimpleMap, Self};
    use std::debug::print;

    const GOLD: u64 = 0;
    const SILVER: u64 = 1;

    struct WeightLocation has store, copy, drop {
        g28: SimpleMap<String, u64>,
        g57: SimpleMap<String, u64>,
        g114: SimpleMap<String, u64>,
    }

    struct Vault has key, copy, drop {
        gold: WeightLocation,
        silver: WeightLocation
    }

    fun init_client(sig: &signer){
        let loc_map: SimpleMap<String, u64> = simple_map::create();
        simple_map::add(&mut loc_map, utf8(b"UAE"), 0);
        simple_map::add(&mut loc_map, utf8(b"MEX"), 0);
        simple_map::add(&mut loc_map, utf8(b"COL"), 0);
        let weightLocation = WeightLocation {
            g28: loc_map,
            g57: loc_map,
            g114: loc_map,
        };
        let vault = Vault {
            gold: weightLocation,
            silver: weightLocation
        };
        move_to(sig, vault);
    }

    fun get_vault(user: address): (WeightLocation, WeightLocation) acquires Vault {
        (borrow_global<Vault>(user).gold, borrow_global<Vault>(user).silver)
    }

    fun read_balances(asset_bal: SimpleMap<String, u64>, grams: String) {
        print(&grams);
        print(&utf8(b"UAE"));
        print(simple_map::borrow(&mut asset_bal, &utf8(b"UAE")));
        print(&utf8(b"COL"));
        print(simple_map::borrow(&mut asset_bal, &utf8(b"COL")));
        print(&utf8(b"MEX"));
        print(simple_map::borrow(&mut asset_bal, &utf8(b"MEX")));
    }


    #[test_only]
    use std::signer;

    #[test(user1 = @0x123, user2 = @0x144)]
    fun reserve_vault1(user1: signer, user2: signer) acquires Vault {
        init_client(&user1);
        init_client(&user2);
        assert!(exists<Vault>(signer::address_of(&user1)) == true, 101);
        assert!(exists<Vault>(signer::address_of(&user2)) == true, 101);

        add_metal(signer::address_of(&user1), utf8(b"UAE"), GOLD, 3, 57);
        add_metal(signer::address_of(&user1), utf8(b"COL"), GOLD, 5, 28);
        add_metal(signer::address_of(&user2), utf8(b"UAE"), SILVER, 6, 57);
        get_client_balance(signer::address_of(&user1), GOLD);
        get_client_balance(signer::address_of(&user2), SILVER);
    }
}