#[test_only]
module dao_addr::test_utils {
    use std::signer;
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use aptos_framework::timestamp;

    struct TestData has key {
        mint_cap: coin::MintCapability<aptos_coin::AptosCoin>,
        burn_cap: coin::BurnCapability<aptos_coin::AptosCoin>,
    }

    public fun setup_aptos(account: &signer) {
        timestamp::set_time_has_started_for_testing(account);
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(account);
        move_to(account, TestData { mint_cap, burn_cap });
    }

    public fun setup_test_account(account: &signer) acquires TestData {
        // First ensure framework account is setup
        let aptos_framework = account::create_signer_for_test(@0x1);
        if (!exists<TestData>(@0x1)) {
            setup_aptos(&aptos_framework);
        };
        
        // Register coin for the test account
        coin::register<aptos_coin::AptosCoin>(account);
        
        // Mint and deposit coins
        let mint_cap = &borrow_global<TestData>(@0x1).mint_cap;
        let coins = coin::mint(1000000, mint_cap);
        coin::deposit(signer::address_of(account), coins);
    }

    public fun mint_aptos(account: &signer, amount: u64) acquires TestData {
        let mint_cap = &borrow_global<TestData>(@0x1).mint_cap;
        let coins = coin::mint(amount, mint_cap);
        coin::deposit(signer::address_of(account), coins);
    }

    public fun destroy_caps(account: &signer) acquires TestData {
        if (exists<TestData>(signer::address_of(account))) {
            let TestData { mint_cap, burn_cap } = move_from<TestData>(signer::address_of(account));
            coin::destroy_mint_cap<aptos_coin::AptosCoin>(mint_cap);
            coin::destroy_burn_cap<aptos_coin::AptosCoin>(burn_cap);
        }
    }

    #[test_only]
    public fun set_time_for_test(time_secs: u64) {
        timestamp::update_global_time_for_test_secs(time_secs);
    }
}