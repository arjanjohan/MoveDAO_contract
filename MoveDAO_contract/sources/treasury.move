module dao_addr::treasury {
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use dao_addr::admin;

    const ENOT_ADMIN: u64 = 2;

    struct Treasury has key {
        balance: coin::Coin<AptosCoin>,
    }

    public entry fun initialize(account: &signer) {
        let addr = signer::address_of(account);
        assert!(!exists<Treasury>(addr), 1);
        move_to(account, Treasury { 
            balance: coin::zero<AptosCoin>(),
        });
    }

    public entry fun deposit(account: &signer, amount: u64) acquires Treasury {
        let addr = signer::address_of(account);
        let treasury = borrow_global_mut<Treasury>(addr);
        let coins = coin::withdraw<AptosCoin>(account, amount);
        coin::merge(&mut treasury.balance, coins);
    }

    public entry fun withdraw(account: &signer, amount: u64) acquires Treasury {
        let addr = signer::address_of(account);
        assert!(admin::is_admin(addr, signer::address_of(account)), ENOT_ADMIN);
        
        let treasury = borrow_global_mut<Treasury>(addr);
        let coins = coin::extract(&mut treasury.balance, amount);
        coin::deposit(signer::address_of(account), coins);
    }

    #[view]
    public fun get_balance(addr: address): u64 acquires Treasury {
        let treasury = borrow_global<Treasury>(addr);
        coin::value(&treasury.balance)
    }
}