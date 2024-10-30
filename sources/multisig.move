//modified from MetaSchool https://github.com/0xmetaschool/contracts-management-aptosc5/blob/boilerplate_01/sources/HashSign.move

module publisher::multisig {
  use std::signer;
  use std::string::String; //{utf8, String};
  use std::vector;
  //use std::option;
  //use std::error;
  use aptos_framework::account::new_event_handle;
  use aptos_framework::event;
  use aptos_framework::timestamp;
  use aptos_framework::simple_map::{Self, SimpleMap};

  struct Election has store, drop, copy {
    id: u64, //election id
    content_hash: String,
    author: address,
    voters: vector<address>,
    votes: vector<Vote>,
    is_completed: bool
  }

  struct Vote has store, drop, copy {
    signer: address,
    timestamp: u64
  }

  struct VoteMapStore has key {
    votes: SimpleMap<u64, Election>,
    count: u64
  }

  // ----------- Events
  struct AddElectionEvent has drop, store {
    election_id: u64,
    author: address
  }

  struct VoteEvent has drop, store {
    election_id: u64,
    signer: address
  }

  // Define a structure to handle events
  struct EventStore has key {
    add_election_events: event::EventHandle<AddElectionEvent>,
    vote_events: event::EventHandle<VoteEvent>
  }

  // ----------- Error Code
  // -----------
  fun init_module(signr: &signer) {
    move_to(
      signr,
      VoteMapStore { votes: simple_map::create(), count: 0 }
    );
    move_to(
      signr,
      EventStore {
        add_election_events: new_event_handle<AddElectionEvent>(signr),
        vote_events: new_event_handle<VoteEvent>(signr)
      }
    );
  }

  public entry fun add_election(
    signr: &signer, content_hash: String, voters: vector<address>
  ) acquires VoteMapStore, EventStore {

    let author = std::signer::address_of(signr);
    let store = borrow_global_mut<VoteMapStore>(@publisher);

    let event_store = borrow_global_mut<EventStore>(@publisher);

    let election = Election {
      id: store.count,
      content_hash,
      author: author,
      voters,
      votes: vector::empty<Vote>(),
      is_completed: false
    };

    simple_map::add(&mut store.votes, store.count, election);

    event::emit_event(
      &mut event_store.add_election_events,
      AddElectionEvent { election_id: store.count, author: author }
    );
    store.count = store.count + 1;
  }

  public entry fun vote(signr: &signer, election_id: u64) acquires VoteMapStore, EventStore {

    let signd = signer::address_of(signr);
    let store = borrow_global_mut<VoteMapStore>(@publisher);
    let event_store = borrow_global_mut<EventStore>(@publisher);

    assert!(simple_map::contains_key(&store.votes, &election_id), 3);

    let election = simple_map::borrow_mut(&mut store.votes, &election_id);
    assert!(!election.is_completed, 1);
    assert!(vector::contains(&election.voters, &signd), 2); //signr is allowed to vote

    let vote = Vote { signer: signd, timestamp: timestamp::now_microseconds() };

    // Add the new vote
    vector::push_back(&mut election.votes, vote);

    event::emit_event(
      &mut event_store.vote_events,
      VoteEvent { election_id, signer: signd }
    );

    if (vector::length(&election.votes) == vector::length(&election.voters)) {
      election.is_completed = true;
    }
  }

  // Get a election by its ID
  #[view]
  public fun get_election(election_id: u64): Election acquires VoteMapStore {
    let store = borrow_global<VoteMapStore>(@publisher);
    assert!(simple_map::contains_key(&store.votes, &election_id), 4);

    *simple_map::borrow(&store.votes, &election_id)
  }

  #[view]
  public fun get_all_elections(): vector<Election> acquires VoteMapStore {
    let store = borrow_global<VoteMapStore>(@publisher);
    let docs = vector::empty<Election>();
    let i = 0;

    while (i < store.count) {
      if (simple_map::contains_key(&store.votes, &i)) {
        vector::push_back(&mut docs, *simple_map::borrow(&store.votes, &i));
      };
      i = i + 1;
    };
    docs
  }

  #[view]
  public fun get_election_count(): u64 acquires VoteMapStore {
    let store = borrow_global<VoteMapStore>(@publisher);
    store.count
  }
}
