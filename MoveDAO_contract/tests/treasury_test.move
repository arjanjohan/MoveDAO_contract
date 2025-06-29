#[test_only]
module dao_addr::treasury_test {
    use std::vector;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;
    use dao_addr::dao_core;
    use dao_addr::treasury;
    use dao_addr::test_utils;

    const EASSERTION_FAILED: u64 = 1000;

    #[test(aptos_framework = @0x1, alice = @0x123)]
    fun test_initialize_only(aptos_framework: &signer, alice: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@0x123);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);

        let council = vector::singleton(@0x123);
        dao_core::create_dao(
            alice, string::utf8(b"Test DAO"), string::utf8(b"Description"),
            b"logo", b"bg", council, 30, 3600, 86400
        );
        treasury::initialize(alice);

        let balance = treasury::get_balance(@0x123);
        assert!(balance == 0, EASSERTION_FAILED);

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, alice = @0x123)]
    fun test_deposit_withdraw(aptos_framework: &signer, alice: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@0x123);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);

        coin::register<AptosCoin>(alice);
        let council = vector::singleton(@0x123);
        dao_core::create_dao(
            alice, string::utf8(b"Test DAO"), string::utf8(b"Description"),
            b"logo", b"bg", council, 30, 3600, 86400
        );
        treasury::initialize(alice);

        test_utils::mint_aptos(alice, 1000);
        treasury::deposit(alice, 500);

        let balance = treasury::get_balance(@0x123);
        assert!(balance == 500, EASSERTION_FAILED + 1);

        treasury::withdraw(alice, 200);
        let new_balance = treasury::get_balance(@0x123);
        assert!(new_balance == 300, EASSERTION_FAILED + 2);

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, alice = @0x123)]
    #[expected_failure(abort_code = treasury::ENOT_ADMIN)]
    fun test_non_admin_cannot_withdraw(aptos_framework: &signer, alice: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@0x123);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);

        coin::register<AptosCoin>(alice);
        let council = vector::singleton(@0x123);
        dao_core::create_dao(
            alice, string::utf8(b"Test DAO"), string::utf8(b"Description"),
            b"logo", b"bg", council, 30, 3600, 86400
        );
        treasury::initialize(alice);

        test_utils::mint_aptos(alice, 1000);
        treasury::deposit(alice, 500);

        let non_admin = account::create_signer_for_test(@0x999);
        treasury::withdraw(&non_admin, 200);  // expected abort

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, alice = @0x123)]
    fun test_multiple_deposits(aptos_framework: &signer, alice: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@0x123);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);

        coin::register<AptosCoin>(alice);
        let council = vector::singleton(@0x123);
        dao_core::create_dao(
            alice, string::utf8(b"Test DAO"), string::utf8(b"Description"),
            b"logo", b"bg", council, 30, 3600, 86400
        );
        treasury::initialize(alice);

        test_utils::mint_aptos(alice, 2000);
        treasury::deposit(alice, 500);
        treasury::deposit(alice, 300);
        let balance = treasury::get_balance(@0x123);
        assert!(balance == 800, EASSERTION_FAILED + 3);

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, alice = @0x123)]
    #[expected_failure]
    fun test_cannot_withdraw_more_than_balance(aptos_framework: &signer, alice: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@0x123);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);

        coin::register<AptosCoin>(alice);
        let council = vector::singleton(@0x123);
        dao_core::create_dao(
            alice, string::utf8(b"Test DAO"), string::utf8(b"Description"),
            b"logo", b"bg", council, 30, 3600, 86400
        );
        treasury::initialize(alice);

        test_utils::mint_aptos(alice, 1000);
        treasury::deposit(alice, 500);
        treasury::withdraw(alice, 501);  // expected abort

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, alice = @0x123)]
    fun test_zero_deposit_withdraw(aptos_framework: &signer, alice: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@0x123);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);

        coin::register<AptosCoin>(alice);
        let council = vector::singleton(@0x123);
        dao_core::create_dao(
            alice, string::utf8(b"Test DAO"), string::utf8(b"Description"),
            b"logo", b"bg", council, 30, 3600, 86400
        );
        treasury::initialize(alice);

        // Test zero deposit
        treasury::deposit(alice, 0);
        assert!(treasury::get_balance(@0x123) == 0, EASSERTION_FAILED + 4);

        test_utils::mint_aptos(alice, 100);
        treasury::deposit(alice, 100);
        
        // Test zero withdraw
        treasury::withdraw(alice, 0);
        assert!(treasury::get_balance(@0x123) == 100, EASSERTION_FAILED + 5);

        test_utils::destroy_caps(aptos_framework);
    }
}