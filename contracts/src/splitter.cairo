use core::zeroable::Zeroable;
use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TStorage> {
    fn transfer(ref self: TStorage, recipient: ContractAddress, amount: u256);
    fn balanceOf(self: @TStorage, account: ContractAddress) -> u256;
}

#[starknet::interface]
trait ISplitter<TStorage> {
    fn totalShares(self: @TStorage) -> u256;
    fn totalReleased(self: @TStorage) -> u256;
    fn shares(self: @TStorage, account: ContractAddress) -> u256;
    fn released(self: @TStorage, account: ContractAddress) -> u256;
    fn release(ref self: TStorage, account: ContractAddress) -> bool;
    fn token(self: @TStorage) -> ContractAddress;
}

#[starknet::contract]
mod Splitter {
    use super::{IERC20Dispatcher, IERC20DispatcherTrait, ISplitter, ContractAddress};
    use array::ArrayTrait;
    use starknet::get_contract_address;

    #[storage]
    struct Storage {
        _totalShares: u256, 
        _totalReleased: u256,
        _shares: LegacyMap::<ContractAddress, u256>,
        _released: LegacyMap::<ContractAddress, u256>,
        _token: ContractAddress,
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
    fn constructor(ref self: ContractState, token_address: ContractAddress, payees: Array<ContractAddress>, shares: Array<u256>) {
        assert(payees.len() == shares.len(), 'WRONG_ARGUMENT_LENGTH');
        self._token.write(token_address);
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
        fn token(self: @ContractState) -> ContractAddress {
            self._token.read()
        }
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
            let _shares = self._shares.read(account);
            let _released = self._released.read(account);
            assert(_shares > 0_u256, 'account has no shares');
            let token = IERC20Dispatcher { contract_address: self._token.read()};
            let totalReceived = token.balanceOf(get_contract_address()) + self._totalReleased.read();

            let payment = (totalReceived * _shares / self._totalShares.read()) - _released;
            assert(payment != 0_u256, 'account is not due payment');

            self._released.write(account, self._released.read(account) + payment);
            self._totalReleased.write(self._totalReleased.read() + payment);
            token.transfer(account, payment);
            self.emit(PaymentReleased {to: account, amount: payment});
            true
        }
    }
}
