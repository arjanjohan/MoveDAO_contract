module dao_addr::council {
    use std::vector;
    use std::option;
    use std::signer;
    use std::error;
    use dao_addr::admin;

    const ENOT_ADMIN: u64 = 1;
    const ECOUNCIL_MEMBER_NOT_FOUND: u64 = 2;
    const EMIN_MEMBERS_CONSTRAINT: u64 = 8;
    const EMAX_MEMBERS_CONSTRAINT: u64 = 9;

    struct CouncilConfig has key {
        members: vector<address>,
        min_members: u64,
        max_members: u64
    }

    public fun init_council(
        account: &signer,
        initial_members: vector<address>,
        min_members: u64,
        max_members: u64
    ) {
        let addr = signer::address_of(account);
        assert!(!exists<CouncilConfig>(addr), error::already_exists(0));
        // Changed to allow empty initial council
        assert!(vector::length(&initial_members) <= max_members, error::invalid_argument(EMAX_MEMBERS_CONSTRAINT));

        move_to(account, CouncilConfig {
            members: initial_members,
            min_members,
            max_members
        });
    }

    public fun add_council_member(admin: &signer, new_member: address) acquires CouncilConfig {
        let addr = signer::address_of(admin);
        assert!(admin::is_admin(addr, addr), error::invalid_argument(ENOT_ADMIN));

        let config = borrow_global_mut<CouncilConfig>(addr);
        let current_len = vector::length(&config.members);
        assert!(current_len < config.max_members, error::invalid_argument(EMAX_MEMBERS_CONSTRAINT));

        vector::push_back(&mut config.members, new_member);
    }

    public fun remove_council_member(admin: &signer, member: address) acquires CouncilConfig {
        let addr = signer::address_of(admin);
        assert!(admin::is_admin(addr, addr), error::invalid_argument(ENOT_ADMIN));

        let config = borrow_global_mut<CouncilConfig>(addr);
        let index_option = find_index(&config.members, member);
        assert!(option::is_some(&index_option), error::invalid_argument(ECOUNCIL_MEMBER_NOT_FOUND));

        let index = option::extract(&mut index_option);
        vector::remove(&mut config.members, index);

        assert!(vector::length(&config.members) >= config.min_members, error::invalid_argument(EMIN_MEMBERS_CONSTRAINT));
    }

    public fun replace_council_member(
        admin: &signer,
        old_member: address,
        new_member: address
    ) acquires CouncilConfig {
        let addr = signer::address_of(admin);
        assert!(admin::is_admin(addr, addr), error::invalid_argument(ENOT_ADMIN));

        let config = borrow_global_mut<CouncilConfig>(addr);
        let index_option = find_index(&config.members, old_member);
        assert!(option::is_some(&index_option), error::invalid_argument(ECOUNCIL_MEMBER_NOT_FOUND));

        let index = option::extract(&mut index_option);
        *vector::borrow_mut(&mut config.members, index) = new_member;
    }

    public fun get_council_members(addr: address): vector<address> acquires CouncilConfig {
        let config = borrow_global<CouncilConfig>(addr);
        config.members
    }

    public fun is_council_member(addr: address, member: address): bool acquires CouncilConfig {
        let config = borrow_global<CouncilConfig>(addr);
        vector::contains(&config.members, &member)
    }

    fun find_index(vec: &vector<address>, value: address): option::Option<u64> {
        let len = vector::length(vec);
        let i = 0;
        while (i < len) {
            if (*vector::borrow(vec, i) == value) {
                return option::some(i)
            };
            i = i + 1;
        };
        option::none()
    }
}