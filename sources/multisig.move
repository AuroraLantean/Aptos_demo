//modified from MetaSchool https://github.com/0xmetaschool/contracts-management-aptosc5/blob/boilerplate_01/sources/HashSign.move

module publisher::multisig {
  //use std::error;
  use std::signer;
  use std::string::String; //{utf8, String};
  use std::vector;
  use std::option;
  use aptos_framework::account;
  use aptos_framework::event;
  use aptos_framework::timestamp;
  use aptos_framework::simple_map::{Self, SimpleMap};

  struct Document has store, drop, copy {
    id: u64, //document id
    content_hash: String,
    author: address,
    signers: vector<address>,
    signatures: vector<Signature>,
    is_completed: bool
  }

  struct Signature has store, drop, copy {
    signer: address,
    timestamp: u64
  }

  struct GlobalDocumentStore has key {
    documents: SimpleMap<u64, Document>,
    document_counter: u64
  }

  // ----------- Events
  struct AddDocumentEvent has drop, store {
    document_id: u64,
    author: address
  }

  struct SignDocumentEvent has drop, store {
    document_id: u64,
    signer: address
  }

  // Define a structure to handle events
  struct EventStore has key {
    add_document_events: event::EventHandle<AddDocumentEvent>,
    sign_document_events: event::EventHandle<SignDocumentEvent>
  }

  // ----------- Error Code
  const ENOT_OWNER: u64 = 1;
  const ASSET_SYMBOL: vector<u8> = b"UNCN";

  // -----------
  fun init_module(account: &signer) {
    move_to(
      account,
      GlobalDocumentStore { documents: simple_map::create(), document_counter: 0 }
    );
    move_to(
      account,
      EventStore {
        add_document_events: account::new_event_handle<AddDocumentEvent>(account),
        sign_document_events: account::new_event_handle<SignDocumentEvent>(account)
      }
    );
  }

  public entry fun add_document(
    signr: &signer, content_hash: String, signers: vector<address>
  ) acquires GlobalDocumentStore, EventStore {

    let author = std::signer::address_of(signr);
    let store = borrow_global_mut<GlobalDocumentStore>(@publisher);

    let event_store = borrow_global_mut<EventStore>(@publisher);

    let document = Document {
      id: store.document_counter,
      content_hash,
      author: author,
      signers,
      signatures: vector::empty<Signature>(),
      is_completed: false
    };

    simple_map::add(&mut store.documents, store.document_counter, document);

    event::emit_event(
      &mut event_store.add_document_events,
      AddDocumentEvent { document_id: store.document_counter, author: author }
    );
    store.document_counter = store.document_counter + 1;
  }
  //sign_document function

  //get_document function

  //get_all_documents function
  //get_total_document_number
}
