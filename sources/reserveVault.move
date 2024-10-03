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

    fun print_balcs(assets: SimpleMap<String, u64>, grams: String) {
        print(&grams);
        print(&utf8(b"UAE"));
        print(simple_map::borrow(&mut assets, &utf8(b"UAE")));
        print(&utf8(b"COL"));
        print(simple_map::borrow(&mut assets, &utf8(b"COL")));
        print(&utf8(b"MEX"));
        print(simple_map::borrow(&mut assets, &utf8(b"MEX")));
    }

    fun get_user_balance(user: address, asset: u64) acquires Vault {
        let (gold, silver) = get_vault(user);
        if (asset == GOLD){
            print_balcs(gold.g28, utf8(b"28 Grams"));
            print_balcs(gold.g57, utf8(b"57 Grams"));
            print_balcs(gold.g114, utf8(b"114 Grams"));
        }
        else {
            print_balcs(silver.g28, utf8(b"28 Grams"));
            print_balcs(silver.g57, utf8(b"57 Grams"));
            print_balcs(silver.g114, utf8(b"114 Grams"));
        }
    }

    fun update_balance(metal: &mut WeightLocation, bar_amt: u64, weight: u64, country: String): bool {
        if (weight == 28){
            let current = simple_map::borrow_mut(&mut metal.g28, &country);
            *current = bar_amt + *current;
            true
        }
        else if(weight == 57){
            let current = simple_map::borrow_mut(&mut metal.g57, &country);
            *current = bar_amt + *current;
            true
        }
        else {
            let current = simple_map::borrow_mut(&mut metal.g114, &country);
            *current = bar_amt + *current;
            true
        }
    }

    fun add_metal(user: address, country: String, type: u64, bar_amt: u64, weight: u64): bool acquires Vault {
        if (type == GOLD) {
            let metal = &mut borrow_global_mut<Vault>(user).gold;
            update_balance(metal, bar_amt, weight, country)
        }
        else {
            let metal = &mut borrow_global_mut<Vault>(user).silver;
            update_balance(metal, bar_amt, weight, country)
        }
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
        add_metal(signer::address_of(&user2), utf8(b"UAE"), SILVER, 6, 114);
				
				print(&utf8(b"--------== User1 Gold"));
        get_user_balance(signer::address_of(&user1), GOLD);
				print(&utf8(b"--------== User2 Silver"));
        get_user_balance(signer::address_of(&user2), SILVER);
    }
}