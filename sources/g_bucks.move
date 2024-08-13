module g_bucks::coin {
    use std::option;                            // Importing the Option module for handling optional values
    use sui::coin::{Self, Coin, TreasuryCap};   // Importing necessary types and functions from the sui::coin module
    use sui::transfer;                          // Importing the transfer module for handling asset transfers
    use sui::tx_context::{Self, TxContext};     // Importing the transaction context module for accessing transaction-related data

    /// Struct defining the COIN type
    /// This struct is used as a phantom type parameter for the G-Bucks token.
    struct COIN has drop {}                      // The `drop` ability allows the COIN struct to be dropped (destroyed)

    /// Function to initialize the G-Bucks currency
    /// This function creates the G-Bucks currency, mints the initial supply, and assigns the treasury capabilities to the transaction sender.
    fun init(witness: COIN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<COIN>(
            witness,                               // The COIN witness to ensure the correct type is used
            2,                                     // Decimal places for the currency
            b"COIN",                               // Short name for the currency
            b"First Coin",                         // Display name for the currency
            b"This is my first coin",              // Description of the currency
            option::none(),                        // Optional URL for the currency's icon (none in this case)
            ctx                                    // The transaction context
        );

        transfer::public_freeze_object(metadata);  // Freezing the metadata to prevent further changes
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));  // Transferring the treasury capability to the transaction sender
    }

    /// Public function to mint new G-Bucks
    /// This function allows minting new G-Bucks by increasing the total supply and returning the minted coins.
    public fun mint(
        treasury_cap: &mut TreasuryCap<COIN>,      // The mutable reference to the treasury capability for COIN
        amount: u64,                               // The amount of G-Bucks to mint
        ctx: &mut TxContext                        // The transaction context
    ): Coin<COIN> {
        coin::mint(treasury_cap, amount, ctx)      // Calling the mint function to create new coins
    }

    /// Entry function to mint and transfer G-Bucks
    /// This function mints a specified amount of G-Bucks and immediately transfers them to a recipient.
    public entry fun mint_and_transfer(
        treasury_cap: &mut TreasuryCap<COIN>,      // The mutable reference to the treasury capability for COIN
        amount: u64,                               // The amount of G-Bucks to mint
        recipient: address,                        // The recipient's address
        ctx: &mut TxContext                        // The transaction context
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx);  // Mint and transfer the coins to the recipient
    }

    /// Entry function to burn G-Bucks
    /// This function burns a specified amount of G-Bucks, reducing the total supply.
    public entry fun burn(
        treasury_cap: &mut TreasuryCap<COIN>,      // The mutable reference to the treasury capability for COIN
        coin: Coin<COIN>                           // The coin to be burned
    ) {
        coin::burn(treasury_cap, coin);            // Calling the burn function to destroy the specified coins
    }
}
