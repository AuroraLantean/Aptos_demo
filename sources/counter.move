module publisher::counter {
	use std::signer;
	use std::debug::print;
  use std::string::{utf8, String};
  //use std::error;

	const ADDR1: address = @publisher;
	const DNOT_EXIST: u64 = 100;		
	
	struct Holder has key {
		count: u64,
		mesg: String,
	}
	
  #[view]
	public fun get_count(addr: address): u64 acquires Holder 
	{
		assert!(exists<Holder>(addr), DNOT_EXIST);
		borrow_global<Holder>(addr).count
	}
  #[view]
	public fun get_mesg(addr: address): String acquires Holder 
	{
		assert!(exists<Holder>(addr), DNOT_EXIST);
		//error::not_found(ENO_MESSAGE));
		borrow_global<Holder>(addr).mesg
	}
	
	public entry fun increase(account: &signer) acquires Holder
	{
		let addr = signer::address_of(account);
		if(!exists<Holder>(addr)) {
			move_to(account, Holder{
				count: 0,
				mesg: utf8(b""),
				});
		} else {
			let holder = borrow_global_mut<Holder>(addr);
			holder.count = holder.count + 1;
			holder.mesg = utf8(b"one");
		}
	}
}