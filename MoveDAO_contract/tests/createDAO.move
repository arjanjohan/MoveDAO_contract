#[test_only]
module dao_addr::create_dao_tests {
    use std::vector;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::timestamp;
    use dao_addr::dao_core;
    use dao_addr::test_utils;

    const EASSERTION_FAILED: u64 = 200;

    #[test(aptos_framework = @0x1, creator = @0x123)]
    fun test_dao_creation(aptos_framework: &signer, creator: &signer) {
        account::create_account_for_test(@0x1);
        account::create_account_for_test(@0x123);
        timestamp::set_time_has_started_for_testing(aptos_framework);
        test_utils::setup_aptos(aptos_framework);

        let name = string::utf8(b"My DAO");
        let description = string::utf8(b"A test DAO");
        dao_core::create_dao(
            creator, name, description, b"logo", b"bg",
            vector::empty(), 30, 3600, 86400
        );

        assert!(*string::bytes(&name) == b"My DAO", EASSERTION_FAILED);
        assert!(*string::bytes(&description) == b"A test DAO", EASSERTION_FAILED + 1);

        test_utils::destroy_caps(aptos_framework);
    }
}