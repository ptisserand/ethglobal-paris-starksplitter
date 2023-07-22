use starknet::ContractAddress;

#[starknet::interface]
trait ISplitter<TStorage> {
    fn totalShares(self: @TStorage) -> u256;
    fn totalReleased(self: @TStorage) -> u256;
    fn shares(self: @TStorage, account: ContractAddress) -> u256;
    fn released(self: @TStorage, account: ContractAddress) -> u256;
    fn release(ref self: TStorage, account: ContractAddress) -> bool;
}

#[starknet::contract]
mod Splitter {
    use super::{ISplitter, ContractAddress};
    use array::ArrayTrait;

    #[storage]
    struct Storage {
        _totalShares: u256, 
        _totalReleased: u256,
        _shares: LegacyMap::<ContractAddress, u256>,
        _released: LegacyMap::<ContractAddress, u256>,
        // _payees: Array<ContractAddress>,
    }

    #[derive(starknet::Event, Drop)]
    struct PayeeAdded {
        account: ContractAddress,
        shares: u256,
    }

    #[derive(starknet::Event, Drop)]
    struct PaymentReleased {
        to: ContractAddress,
        amount: u256,
    }

    #[derive(starknet::Event, Drop)]
    #[event]
    enum Event {
        PayeeAdded: PayeeAdded,
        PaymentReleased: PaymentReleased,
    }

    #[constructor]
    fn constructor(ref self: ContractState, payees: Array<ContractAddress>, shares: Array<u256>) {
        assert(payees.len() == shares.len(), 'WRONG_ARGUMENT_LENGTH');
        let mut i: usize = 0;
        let mut totalShares: u256 = 0;
        loop {
            if i >= payees.len() {
                break;
            }
            let _payee = *payees.at(i);
            let _share = *shares.at(i);
            self._addPaye(_payee, _share);
            self._released.write(_payee, 0_u256);
            totalShares += _share;
            i += 1;
        };
        
        self._totalShares.write(totalShares);
        self._totalReleased.write(0_u256);
    }

    #[generate_trait]
    impl InternalMethods of InternalMethodsTrait {
        fn _addPaye(ref self: ContractState, account: ContractAddress, shares: u256) {
            self._shares.write(account, shares);
            self.emit(PayeeAdded {account: account, shares: shares});
        }
    }

    #[external(v0)]
    impl SplitterImpl of ISplitter<ContractState> {
        fn totalShares(self: @ContractState) -> u256 {
            self._totalShares.read()
        }

        fn totalReleased(self: @ContractState) -> u256 {
            self._totalReleased.read()
        }

        fn shares(self: @ContractState, account: ContractAddress) -> u256 {
            self._shares.read(account)
        }

        fn released(self: @ContractState, account: ContractAddress) -> u256 {
            self._released.read(account)
        }

        fn release(ref self: ContractState, account: ContractAddress) -> bool {
            true
        }
    }
}
