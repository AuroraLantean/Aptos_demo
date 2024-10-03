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

}