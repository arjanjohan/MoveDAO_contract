#[test_only]
module dao_addr::membership_tests {
    use std::vector;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::timestamp;
    use dao_addr::dao_core;
    use dao_addr::membership;
    use dao_addr::staking;
    use dao_addr::test_utils;

    const TEST_MEMBER: address = @0xA;
    const TEST_MEMBER2: address = @0xB;
    const TEST_MIN_STAKE: u64 = 100;

    #[test(aptos_framework = @0x1, admin = @dao_addr)]
    fun test_membership_lifecycle(aptos_framework: &signer, admin: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(admin);

        let initial_council = vector::singleton(@dao_addr);
        dao_core::create_dao(
            admin, string::utf8(b"Test DAO"),
            string::utf8(b"Description"), b"logo", b"bg",
            initial_council, 30, 3600, 86400
        );
        staking::test_init_module(admin);
        membership::initialize(admin);

        let member1 = account::create_account_for_test(TEST_MEMBER);
        test_utils::setup_test_account(&member1);
        coin::register<aptos_framework::aptos_coin::AptosCoin>(&member1);
        test_utils::mint_aptos(&member1, 1000);

        staking::stake(&member1, TEST_MIN_STAKE);
        membership::join(&member1);
        assert!(membership::is_member(@dao_addr, TEST_MEMBER), 1);
        assert!(membership::total_members(@dao_addr) == 1, 2);
        assert!(membership::get_voting_power(@dao_addr, TEST_MEMBER) == TEST_MIN_STAKE, 3);

        staking::stake(&member1, 500);
        assert!(membership::get_voting_power(@dao_addr, TEST_MEMBER) == TEST_MIN_STAKE + 500, 4);

        membership::leave(&member1);
        assert!(!membership::is_member(@dao_addr, TEST_MEMBER), 5);
        assert!(membership::total_members(@dao_addr) == 0, 6);

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, admin = @dao_addr)]
    #[expected_failure(abort_code = membership::EALREADY_MEMBER)]
    fun test_cannot_join_twice(aptos_framework: &signer, admin: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(admin);

        let initial_council = vector::singleton(@dao_addr);
        dao_core::create_dao(admin, string::utf8(b"Test DAO"), string::utf8(b"Description"),
                             b"logo", b"bg", initial_council, 30, 3600, 86400);
        staking::test_init_module(admin);
        membership::initialize(admin);

        let member = account::create_account_for_test(TEST_MEMBER);
        test_utils::setup_test_account(&member);
        coin::register<aptos_framework::aptos_coin::AptosCoin>(&member);
        test_utils::mint_aptos(&member, 1000);
        staking::stake(&member, TEST_MIN_STAKE);
        membership::join(&member);
        membership::join(&member);  // expected abort

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, admin = @dao_addr)]
    #[expected_failure(abort_code = membership::EMIN_STAKE_REQUIRED)]
    fun test_cannot_join_without_min_stake(aptos_framework: &signer, admin: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(admin);

        let initial_council = vector::singleton(@dao_addr);
        dao_core::create_dao(admin, string::utf8(b"Test DAO"), string::utf8(b"Description"),
                             b"logo", b"bg", initial_council, 30, 3600, 86400);
        staking::test_init_module(admin);
        membership::initialize(admin);

        let member = account::create_account_for_test(TEST_MEMBER);
        test_utils::setup_test_account(&member);
        coin::register<aptos_framework::aptos_coin::AptosCoin>(&member);
        test_utils::mint_aptos(&member, 1000);
        membership::join(&member);  // expected abort

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, admin = @dao_addr)]
    fun test_voting_power_scales_with_stake(aptos_framework: &signer, admin: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(admin);

        let initial_council = vector::singleton(@dao_addr);
        dao_core::create_dao(admin, string::utf8(b"Test DAO"), string::utf8(b"Description"),
                             b"logo", b"bg", initial_council, 30, 3600, 86400);
        staking::test_init_module(admin);
        membership::initialize(admin);

        let member1 = account::create_account_for_test(TEST_MEMBER);
        let member2 = account::create_account_for_test(TEST_MEMBER2);
        test_utils::setup_test_account(&member1);
        test_utils::setup_test_account(&member2);
        coin::register<aptos_framework::aptos_coin::AptosCoin>(&member1);
        coin::register<aptos_framework::aptos_coin::AptosCoin>(&member2);
        test_utils::mint_aptos(&member1, 5000);
        test_utils::mint_aptos(&member2, 3000);

        staking::stake(&member1, 1000);
        membership::join(&member1);
        assert!(membership::get_voting_power(@dao_addr, TEST_MEMBER) == 1000, 1);

        staking::stake(&member2, 2000);
        membership::join(&member2);
        assert!(membership::get_voting_power(@dao_addr, TEST_MEMBER2) == 2000, 2);

        staking::stake(&member1, 500);
        assert!(membership::get_voting_power(@dao_addr, TEST_MEMBER) == 1500, 3);

        assert!(membership::total_voting_power(@dao_addr) == 3500, 4);

        test_utils::destroy_caps(aptos_framework);
    }

    #[test(aptos_framework = @0x1, admin = @dao_addr)]
    fun test_voting_power_decreases_with_unstake(aptos_framework: &signer, admin: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@dao_addr);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);
        test_utils::setup_test_account(admin);

        let initial_council = vector::singleton(@dao_addr);
        dao_core::create_dao(admin, string::utf8(b"Test DAO"), string::utf8(b"Description"),
                             b"logo", b"bg", initial_council, 30, 3600, 86400);
        staking::test_init_module(admin);
        membership::initialize(admin);

        let member = account::create_account_for_test(TEST_MEMBER);
        test_utils::setup_test_account(&member);
        coin::register<aptos_framework::aptos_coin::AptosCoin>(&member);
        test_utils::mint_aptos(&member, 5000);

        staking::stake(&member, 2000);
        membership::join(&member);
        assert!(membership::get_voting_power(@dao_addr, TEST_MEMBER) == 2000, 1);

        staking::unstake(&member, 500);
        assert!(membership::get_voting_power(@dao_addr, TEST_MEMBER) == 1500, 2);

        staking::unstake(&member, 1400);
        assert!(membership::is_member(@dao_addr, TEST_MEMBER), 3);
        assert!(membership::get_voting_power(@dao_addr, TEST_MEMBER) == 100, 4);

        test_utils::destroy_caps(aptos_framework);
    }
}