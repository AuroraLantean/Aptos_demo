module publisher::price_oracle {
    use std::vector;
    use std::string::{String, utf8};
    use std::timestamp;
    use std::signer;

    const ENOT_OWNER: u64 = 101;

    struct TokenFeed has store, drop, copy {
        last_price: u64,
        timestamp: u64
    }

    struct PriceFeeds has key, store, drop, copy {
        symbols: vector<String>,
        data: vector<TokenFeed>
    }

    fun init_module(owner: &signer) {
        let symbols = vector::empty<String>();
        vector::push_back(&mut symbols, utf8(b"BTC"));
        let token_feed = TokenFeed { last_price: 0, timestamp: 0 };
        let data_feed = PriceFeeds { symbols: symbols, data: vector[token_feed] };
        move_to(owner, data_feed);
    }

    fun update_feed(owner: &signer, last_price: u64, symbol: String) acquires PriceFeeds {
        let signer_addr = signer::address_of(owner);
        assert!(signer_addr == @publisher, ENOT_OWNER);
        let time = timestamp::now_seconds();
        let pricefeed = borrow_global_mut<PriceFeeds>(signer_addr);
        let token_feed = TokenFeed { last_price: last_price, timestamp: time };
        let (result, index) = vector::index_of(&mut pricefeed.symbols, &symbol);
        if (result == true) {
            vector::remove(&mut pricefeed.data, index);
            vector::insert(&mut pricefeed.data, index, token_feed);
        } else {
            vector::push_back(&mut pricefeed.symbols, symbol);
            vector::push_back(&mut pricefeed.data, token_feed);
        }
    }

    public fun get_token_price(symbol: String): TokenFeed acquires PriceFeeds {
        let symbols = borrow_global<PriceFeeds>(@publisher).symbols;
        let (result, index) = vector::index_of(&symbols, &symbol);
        if (result == true) {
            let data_feed = borrow_global<PriceFeeds>(@publisher).data;
            *vector::borrow(&data_feed, index)
        } else {
            TokenFeed { last_price: 0, timestamp: 0 }
        }
    }

    #[test_only]
    use std::debug::print;

    #[test(account = @publisher, init_addr = @0x1)]
    fun test_pricefeed(account: signer, init_addr: signer) acquires PriceFeeds {
        timestamp::set_time_has_started_for_testing(&init_addr);
        init_module(&account);
        update_feed(&account, 62040, utf8(b"BTC"));
        update_feed(&account, 2500, utf8(b"ETH"));
        let result = get_token_price(utf8(b"BTC"));
        print(&result);
        result = get_token_price(utf8(b"ETH"));
        print(&result);
        result = get_token_price(utf8(b"APT"));
        print(&result);
        update_feed(&account, 62140, utf8(b"BTC"));
        result = get_token_price(utf8(b"BTC"));
        print(&result);
    }
}
