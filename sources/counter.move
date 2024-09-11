module publisher::counter {
	use std::signer;
	use std::debug::print;
  //use std::string::{utf8, String};
  //use std::error;

	const DOSENOT_EXIST: u64 = 100;
	const ADDR1: address = @publisher;
	
	struct CounterHolder has key {
		count: u64
	}
	
  #[view]
	public fun get_count(addr: address): u64 acquires CounterHolder 
	{
		assert!(exists<CounterHolder>(addr), DOSENOT_EXIST);
		borrow_global<CounterHolder>(addr).count
	}
	
	public entry fun increase(account: &signer) acquires CounterHolder
	{
		let addr = signer::address_of(account);
		if(!exists<CounterHolder>(addr)) {
			move_to(account, CounterHolder{
				count: 0
				});
		} else {
			let holder = borrow_global_mut<CounterHolder>(addr);
			holder.count = holder.count + 1;
		}
	}
}