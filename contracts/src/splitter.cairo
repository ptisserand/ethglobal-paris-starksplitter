use array::ArrayTrait;
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
    use super::{ISplitter, ContractAddress, ISplitterDispatcher, ISplitterDispatcherTrait};

    #[storage]
    struct Storage {
        _totalShares: u256, // needed ?
        _totalReleased: u256, // needed ?
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
    struct PaymentReceived {
        from: ContractAddress,
        amount: u256,
    }

    #[derive(starknet::Event, Drop)]
    #[event]
    enum Event {
        PayeeAdded: PayeeAdded,
        PaymentReleased: PaymentReleased,
        PaymentReceived: PaymentReceived,
    }

    #[constructor]
    fn constructor(ref self: ContractState, payees: Array<ContractAddress>, shares: Array<u256>) {

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
            1234_u256
        }

        fn released(self: @ContractState, account: ContractAddress) -> u256 {
            1234_u256
        }

        fn release(ref self: ContractState, account: ContractAddress) -> bool {
            false
        }
    }
}
