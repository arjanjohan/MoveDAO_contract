module dao_addr::dao_core {
    use std::signer;
    use std::string;
    use std::error;
    use aptos_framework::timestamp;
    use dao_addr::admin;
    use dao_addr::council;
    use dao_addr::membership;
    use dao_addr::proposal;
    use dao_addr::council::CouncilConfig;
    use aptos_framework::object::Object;

    struct DAOInfo has key {
        name: string::String,
        description: string::String,
        logo: vector<u8>,
        background: vector<u8>,
        created_at: u64,
        council: Object<CouncilConfig>
    }

    public entry fun create_dao(
        account: &signer,
        name: string::String,
        description: string::String,
        logo: vector<u8>,
        background: vector<u8>,
        initial_council: vector<address>,
        _min_quorum_percent: u64, // Marked as unused with underscore
        min_voting_period: u64,
        max_voting_period: u64
    ) {
        let addr = signer::address_of(account);
        assert!(!exists<DAOInfo>(addr), error::already_exists(0));


        let council = council::init_council(account, initial_council, 1, 10);

        move_to(account, DAOInfo {
            name,
            description,
            logo,
            background,
            created_at: timestamp::now_seconds(),
            council
        });

        // Initialize all required modules
        admin::init_admin(account, 1);
        membership::initialize(account);
        proposal::initialize_proposals(account, min_voting_period, max_voting_period);


    }

    #[view]
    public fun get_dao_info(addr: address): (string::String, string::String, vector<u8>, vector<u8>, u64)
    acquires DAOInfo {
        let dao = borrow_global<DAOInfo>(addr);
        (
            dao.name,
            dao.description,
            dao.logo,
            dao.background,
            dao.created_at
        )
    }
}