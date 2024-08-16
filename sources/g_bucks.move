module g_bucks::coin {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self as tx_context, TxContext};
    use sui::object::{Self as sui_object, UID};

    struct COIN has drop {} // The `drop` ability allows the COIN struct to be dropped (destroyed)

    struct CoinOwner has key{ // Added 'store' ability
        id: UID,              // Unique ID for the CoinOwner object
        owner: address,       // Address of the coin owner
    }

struct TransferCap has key {
    id: UID,
}
    fun init(witness: COIN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<COIN>(
            witness,                               // The COIN witness to ensure the correct type is used
            1,                                     // Decimal places for the currency
            b"G-Bucks",                            // Short name for the currency
            b"Gamisode Bucks",                     // Display name for the currency
            b"the Coins for the Gamisodes Platform", // Description of the currency
            option::none(),                        // Optional URL for the currency's icon (none in this case)
            ctx                                    // The transaction context
        );

let transfer_cap = TransferCap {

            id: sui_object::new(ctx),             // Generate a new UID for the CoinOwner object
        };
        let owner = CoinOwner {
            id: sui_object::new(ctx),             // Generate a new UID for the CoinOwner object
            owner: tx_context::sender(ctx),       // Store the sender's address as the owner
        };
        transfer ::transfer(transfer_cap,tx_context::sender(ctx));
        transfer::public_freeze_object(metadata); // Freezing the metadata to prevent further changes
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx)); // Transferring the treasury capability to the transaction sender
        // Transfer the CoinOwner object to the sender
        transfer::transfer(owner, tx_context::sender(ctx));
    }

    // public entry fun mint(
    //     _transfer_cap: &mut TransferCap,
    //     treasury_cap: &mut TreasuryCap<COIN>, // The mutable reference to the treasury capability for COIN
        
    //     amount: u64,                          // The amount of G-Bucks to mint
    //     ctx: &mut TxContext                   // The transaction context
    // ) {
    //     let minted_coins = coin::mint(treasury_cap, amount, ctx);
    //     transfer::public_transfer(minted_coins, tx_context::sender(ctx));
    // }

    // public entry fun transfer(
    //     _transfer_cap: &mut TransferCap,
    //     coin: Coin<COIN>,
    //     recipient: address,
    //     ctx: &mut TxContext
    // ) {
    //     let owner_obj = tx_context::sender(ctx); // Retrieve the owner's address

    //     // Ensure that only the owner can call this function
    //     assert!(tx_context::sender(ctx) == owner_obj, 0x1);

    //     transfer::public_transfer(coin, recipient);
    // }

    public entry fun mint_and_transfer(
        _transfer_cap: &mut TransferCap,
        treasury_cap: &mut TreasuryCap<COIN>, // The mutable reference to the treasury capability for COIN
        amount: u64,                          // The amount to mint and transfer
        recipient: address,                   // The recipient's address
        ctx: &mut TxContext                   // The transaction context
    ) {
        let minted_coins = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(minted_coins, recipient);
    }


    /// Function to spend G-Bucks by destroying the coin
    public fun spend(
        treasury_cap: &mut TreasuryCap<COIN>,
        coin: Coin<COIN>,       // The coin to be spent
        _ctx: &mut TxContext     // The transaction context (currently unused)
    ) {
        // Destroy the coin (spend it)
        coin::burn(treasury_cap, coin);

    }
}
