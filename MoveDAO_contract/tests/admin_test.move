#[test_only]
module dao_addr::admin_tests {
    use std::vector;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use dao_addr::dao_core;
    use dao_addr::admin;
    use dao_addr::test_utils;

    const EASSERTION_FAILED: u64 = 200;

    #[test(aptos_framework = @0x1, alice = @dao_addr)]
    fun test_admin_initialization(aptos_framework: &signer, alice: &signer) {
        // Setup framework and test accounts
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        
        // Initialize test environment
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);
        coin::register<aptos_coin::AptosCoin>(alice);

        // Create DAO
        dao_core::create_dao(
            alice, 
            string::utf8(b"Test DAO"), 
            string::utf8(b"Description"),
            b"logo", 
            b"bg", 
            vector::empty(), 
            30, 
            3600, 
            86400
        );

        // Verify admin initialization
        assert!(admin::is_admin(@dao_addr, @dao_addr), EASSERTION_FAILED);
        assert!(
            admin::get_admin_role(@dao_addr, @dao_addr) == admin::role_super_admin(),
            EASSERTION_FAILED + 1
        );

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, alice = @dao_addr, _bob = @0x456)]
    fun test_add_and_remove_admin(aptos_framework: &signer, alice: &signer, _bob: &signer) {
        // Setup accounts
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        account::create_account_for_test(@0x456);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        
        // Initialize test environment
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);
        coin::register<aptos_coin::AptosCoin>(alice);

        // Create DAO
        dao_core::create_dao(
            alice, 
            string::utf8(b"Test DAO"), 
            string::utf8(b"Description"),
            b"logo", 
            b"bg", 
            vector::empty(), 
            30, 
            3600, 
            86400
        );

        // Test admin operations
        admin::add_admin(alice, @0x456, admin::role_standard(), 0);
        assert!(admin::is_admin(@dao_addr, @0x456), EASSERTION_FAILED);
        
        let admins = admin::get_admins(@dao_addr);
        assert!(vector::length(&admins) == 2, EASSERTION_FAILED + 1);
        
        admin::remove_admin(alice, @0x456);
        assert!(!admin::is_admin(@dao_addr, @0x456), EASSERTION_FAILED + 2);

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, alice = @dao_addr)]
    #[expected_failure(abort_code = admin::EINVALID_ROLE)]
    fun test_invalid_role_rejected(aptos_framework: &signer, alice: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);
        coin::register<aptos_coin::AptosCoin>(alice);

        dao_core::create_dao(
            alice, 
            string::utf8(b"Test DAO"), 
            string::utf8(b"Description"),
            b"logo", 
            b"bg", 
            vector::empty(), 
            30, 
            3600, 
            86400
        );

        admin::add_admin(alice, @dao_addr, 42, 0); // Should fail with EINVALID_ROLE

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, alice = @dao_addr, _bob = @0x456)]
    #[expected_failure(abort_code = admin::ENOT_ADMIN)]
    fun test_super_admin_protection(aptos_framework: &signer, alice: &signer, _bob: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        account::create_account_for_test(@0x456);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);
        coin::register<aptos_coin::AptosCoin>(alice);

        dao_core::create_dao(
            alice, 
            string::utf8(b"Test DAO"), 
            string::utf8(b"Description"),
            b"logo", 
            b"bg", 
            vector::empty(), 
            30, 
            3600, 
            86400
        );

        let non_admin = account::create_signer_for_test(@0x999);
        admin::remove_admin(&non_admin, @dao_addr); // Should fail with ENOT_ADMIN

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, alice = @dao_addr, _bob = @0x456)]
    fun test_temporary_admin_expiration(aptos_framework: &signer, alice: &signer, _bob: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        account::create_account_for_test(@0x456);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(alice);
        coin::register<aptos_coin::AptosCoin>(alice);

        dao_core::create_dao(
            alice, 
            string::utf8(b"Test DAO"), 
            string::utf8(b"Description"),
            b"logo", 
            b"bg", 
            vector::empty(), 
            30, 
            3600, 
            86400
        );

        admin::add_admin(alice, @0x456, admin::role_temporary(), 100);
        assert!(admin::is_admin(@dao_addr, @0x456), EASSERTION_FAILED + 3);
        
        timestamp::fast_forward_seconds(101);
        assert!(!admin::is_admin(@dao_addr, @0x456), EASSERTION_FAILED + 4);

        test_utils::destroy_caps(aptos_framework);
    }
}