module publisher::crowdfunding {
  use std::signer;
  //use std::string::String; //{utf8, String};
  use std::vector;
  //use std::option;
  //use std::error;
  //use aptos_framework::account::new_event_handle;
  //use aptos_framework::event;
  //use aptos_framework::timestamp;
  //use aptos_framework::simple_map::{Self, SimpleMap};
  use aptos_framework::coin; //Coin
  use aptos_framework::aptos_coin::AptosCoin;

  // struct VoteMapStore has key {
  //   votes: SimpleMap<u64, Election>,
  //   count: u64
  // }
	
	/* Settings {}
	User { id => contribution }
	update_campaign()
	claim_reward()
	deposit()
	withdraw()
	*/
  struct Campaign has store, key {
    goal_amount: u64,
    current_amount: u64,
    active: bool,
  }

  /// Resource that holds all campaigns
  struct Campaigns has key {
    campaigns: vector<Campaign>,
  }

  // ----------- Events

  // ----------- Error Code
  // -----------
  public entry fun add_campaign(signr: &signer, goal_amount: u64) acquires Campaigns {
    let signrd = signer::address_of(signr);
    if (!exists<Campaigns>(signrd)) {
      move_to(
        signr,
        Campaigns {
          campaigns: vector::empty<Campaign>()
        }
      );// Add a new campaign to the signr
    };
    let campaigns = borrow_global_mut<Campaigns>(signrd);

    vector::push_back(
      &mut campaigns.campaigns,
      Campaign { goal_amount, current_amount: 0, active: true }
    );
  }

  /// View a campaign of an signr
  public fun view_campaign(addr: address, compain_id: u64): (u64, u64, bool) acquires Campaigns {
    if (!exists<Campaigns>(addr)) {
      return (0, 0, false)
    };

    let campaigns = borrow_global<Campaigns>(addr);
    let campaign = vector::borrow(&campaigns.campaigns, compain_id);
    (campaign.goal_amount, campaign.current_amount, campaign.active)
  }

  public entry fun contribute(
    signr: &signer, campaign_owner: address, compain_id: u64, amount: u64
  ) acquires Campaigns {
    // Transfer the AptosCoins from the contributor's signr to the campaign owner's signr
    coin::transfer<AptosCoin>(signr, campaign_owner, amount);

    // Ensure the campaign exists and is active
    if (!exists<Campaigns>(campaign_owner)) {
      abort 404 // Campaign does not exist
    };

    let campaigns = borrow_global_mut<Campaigns>(campaign_owner);
    let campaign = vector::borrow_mut(&mut campaigns.campaigns, compain_id);
		
    assert!(campaign.active, 403);// invactive

    campaign.current_amount = campaign.current_amount + amount;

    // if the goal is met
    if (campaign.current_amount >= campaign.goal_amount) {
      campaign.active = false;
    };
  }
}
