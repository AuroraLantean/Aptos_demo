//https://aptos.dev/en/build/smart-contracts/aptos-coin
module publisher::moon_coin {
  struct MoonCoin {}

  fun init_module(sender: &signer) {
    aptos_framework::managed_coin::initialize<MoonCoin>(
      sender, b"Moon Coin", b"MOON", 6, false
    ); // due to the way the parallel executor works, turning on this option will prevent any parallel execution of mint and burn. If the coin will be regularly minted or burned, consider disabling monitor_supply.
  }
}
