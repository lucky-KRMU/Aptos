/// A simple token contract on Aptos.
module MyToken::MyToken {
    use std::signer;
    use aptos_framework::coin;
    use std::string;

    /// MyToken is a fungible token. The struct's name serves as the coin's type.
    struct MyToken has store {}

    /// This function must be called by an account before it can receive MyToken.
    public entry fun register(account: &signer) {
        // Registers the account to hold MyToken if it hasn't been already.
        if (!coin::is_account_registered<MyToken>(signer::address_of(account))) {
            coin::register<MyToken>(account);
        }
    }

    /// Initializes the token's metadata and mints the initial supply.
    /// This function should only be called once by the module's creator.
    public entry fun initialize_token(creator: &signer, total_supply: u64) {
        // This function returns three capabilities: burn, freeze, and mint.
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<MyToken>(
            creator,
            string::utf8(b"MyToken"), // Token name
            string::utf8(b"MTK"),     // Token symbol
            6,                       // Decimal places
            true,                    // Monitor supply?
        );

        // Mint the total supply of the token.
        let coin_to_mint = coin::mint<MyToken>(total_supply, &mint_cap);
        
        // The creator must also register to receive the initial supply.
        register(creator);

        // Deposit the newly minted coins into the creator's account.
        coin::deposit(signer::address_of(creator), coin_to_mint);

        // For a fixed-supply token, destroy the capabilities so no more can be minted, burned, or frozen.
        coin::destroy_burn_cap(burn_cap);
        coin::destroy_freeze_cap(freeze_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    /// Transfers an amount of MyToken from the sender to a recipient.
    /// The recipient must have already called the `register` function.
    public entry fun transfer(sender: &signer, recipient: address, amount: u64) {
        coin::transfer<MyToken>(sender, recipient, amount);
    }
}