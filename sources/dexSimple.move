module publisher::Sample8 {

    const E_NOTENOUGH: u64 = 0;

    const SymbolN2DR: u64 = 1;
    const SymbolAPT: u64 = 2;
    const SymbolWETH: u64 = 3;

    const Pool1_usdt: u64 = 3201;
    const Pool1_n2dr: u64 = 312;
    const N2DR_name: vector<u8> = b"N2DR";

    const Pool2_usdt: u64 = 124700;
    const Pool2_apt: u64 = 21500;
    const APT_name: vector<u8> = b"APT";

    const Pool3_usdt: u64 = 2750000;
    const Pool3_weth: u64 = 1310;
    const WETH_name: vector<u8> = b"WETH";

    fun get_supply(token_symbol: u64): (u64, u64, vector<u8>) {
        if (token_symbol == SymbolN2DR)
            (Pool1_usdt, Pool1_n2dr, N2DR_name)
        else if (token_symbol == SymbolAPT)
            (Pool2_usdt, Pool2_apt, APT_name)
        else
            (Pool3_usdt, Pool3_weth, WETH_name)
    }

    fun token_price(poolx: u64, pooly: u64): u64 {
        assert!(poolx > 0, E_NOTENOUGH);
        assert!(pooly > 0, E_NOTENOUGH);
        poolx / pooly
    }

    fun calculate_swap(poolx: u64, pooly: u64, amtx: u64): u64 {
        assert!(amtx > 0, E_NOTENOUGH);
        let fee = amtx * 5 / 1000;
	    	// 5% fee of the input amount

        let supply_product: u64 = poolx * pooly;
        let poolx_new = poolx + amtx;
        let pooly_new = supply_product / (poolx_new - fee);
        let amty = pooly - pooly_new;
        amty
    }
/*Liquidity Pool
Pool1x = 3201 USDT
Pool1y = 312 N2DR

Swap amtx 495 CoinUsdt -> amty CoinN2dr 

FORMULA with 5% fee

Apply a 5% fee to the CoinUsdt amount to be swapped. fee = amtx * 5 / 1000 = 2

Multiply both CoinUsdt and CoinN2dr Supply.
  SupplyProduct: Pool1x * Pool1y = 998,712

Determine the new pool balance of CoinUsdt after the swap.
  Pool1xNew: Pool1x + amtx = 3,696

Determine the new pool balance of CoinN2dr after the swap.
  Pool1yNew: SupplyProduct / (Pool1xNew - fee) = 998,712/(3696-2) = 270

Determine the amount of CoinN2dr to transfer to user.
  amty = Pool1y - Pool1yNew = 42   */

    #[test_only]
    use std::debug::print;

    #[test_only]
    use std::string::{utf8};

    #[test]
    fun test_function() {
        let (poolx, pooly, name) = get_supply(SymbolN2DR);//SymbolN2DR, SymbolAPT, SymbolWETH
				
				let swap_amount = 495;//USDT
        //let swap_amount = 2340; 
				print(&utf8(b"Swap:"));
				print(&swap_amount);
        print(&utf8(b"USDT for:"));
        print(&utf8(name));

        print(&utf8(b"Token Price Before Swap"));
        let price_before = token_price(poolx, pooly);
        print(&price_before);

        let amty = calculate_swap(poolx, pooly, swap_amount);
				print(&utf8(b"output token:"));
        print(&amty);

        print(&utf8(b"Token Price After Swap"));
        let poolx_after = poolx + swap_amount;
        let pooly_after = pooly - amty;
        let price_after = token_price(poolx_after, pooly_after);
        print(&price_after);
    }
}