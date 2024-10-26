//https://aptos.dev/en/build/guides/first-fungible-asset#step-433-managing-a-coin

//https://github.com/aptos-labs/aptos-core/blob/50104947083b7c6b3eee9f764f411d3031334a9a/testsuite/module-publish/src/packages/framework_usecases/sources/fungible_asset_example.move#L62
module publisher::fungible_asset {
  use aptos_framework::fungible_asset::{
    Self,
    MintRef,
    TransferRef,
    BurnRef,
    Metadata,
    FungibleAsset
  };
  use aptos_framework::object::{Self, Object};
  use aptos_framework::primary_fungible_store;
  use std::error;
  use std::signer;
  use std::string::utf8;
  use std::option;

  const ENOT_OWNER: u64 = 1;
  const ASSET_SYMBOL: vector<u8> = b"UNCN";

  #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
  /// Hold refs to control the minting, transfer and burning of fungible assets.
  struct ManagedFungibleAsset has key {
    mint_ref: MintRef,
    transfer_ref: TransferRef,
    burn_ref: BurnRef
  }

  fun init_module(admin: &signer) {
    //generate metadata object
    let constructor_ref = &object::create_named_object(admin, ASSET_SYMBOL);

    primary_fungible_store::create_primary_store_enabled_fungible_asset(
      constructor_ref,
      option::none(),
      utf8(b"Unicorn Coin"), /* name */
      utf8(ASSET_SYMBOL), /* symbol */
      8, /* decimals */
      utf8(
        b"https://peach-tough-crayfish-991.mypinata.cloud/ipfs/QmWv9vn1QG2NJ1mFTsZ1sCr48zkmb9kmYQjYJnxSSmuMCj"
      ), /* icon */
      utf8(
        b"https://github.com/AuroraLantean/Aptos_demo"
      ) /* project */
    );

    // Generate mint/burn/transfer refs
    let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
    let burn_ref = fungible_asset::generate_burn_ref(constructor_ref);
    let transfer_ref = fungible_asset::generate_transfer_ref(constructor_ref);

    let metadata_object_signer = object::generate_signer(constructor_ref);
    move_to(
      &metadata_object_signer,
      ManagedFungibleAsset { mint_ref, transfer_ref, burn_ref }
    )
  }

  #[view]
  public fun get_metadata_object(): Object<Metadata> {
    let metadata_addr = object::create_object_address(&@publisher, ASSET_SYMBOL);
    object::address_to_object<Metadata>(metadata_addr)
  }

  public entry fun mint_p(user: &signer, admin: &signer, amount: u64) acquires ManagedFungibleAsset {
    mint(admin, signer::address_of(user), amount);
  }

  public entry fun mint(admin: &signer, to: address, amount: u64) acquires ManagedFungibleAsset {
    let metadata = get_metadata_object();
    let asset_ref = authorized_borrow_refs(admin, metadata);

    let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, metadata);

    let bucket = fungible_asset::mint(&asset_ref.mint_ref, amount);

    fungible_asset::deposit_with_ref(&asset_ref.transfer_ref, to_wallet, bucket);
  }

  /// This validates that the signer is the object's owner. 
	inline fun authorized_borrow_refs(
    owner: &signer, object: Object<Metadata>
  ): &ManagedFungibleAsset acquires ManagedFungibleAsset {
    assert!(
      object::is_owner(object, signer::address_of(owner)),
      error::permission_denied(ENOT_OWNER)
    );
    borrow_global<ManagedFungibleAsset>(object::object_address(&object))
  }
}
