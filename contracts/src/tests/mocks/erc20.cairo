use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TStorage> {
    fn transfer(ref self: TStorage, recipient: ContractAddress, amount: u256);
    fn balanceOf(self: @TStorage, account: ContractAddress) -> u256;
    fn mint(ref self: TStorage, recipient: ContractAddress, amount: u256);
}

#[starknet::contract]
mod ERC20 {
    use super::{IERC20, ContractAddress};
    use starknet::get_caller_address;
    use zeroable::{Zeroable};

    #[storage]
    struct Storage {
        _balances: LegacyMap<ContractAddress, u256>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self._mint(get_caller_address(), 1000_u256);
    }

    #[generate_trait]
    impl InternalMethods of InternalMethodsTrait {
        fn _mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self._balances.write(recipient, self._balances.read(recipient) + amount);
        }
    }

    #[external(v0)]
    impl ERC20Impl of IERC20<ContractState> {
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            self._mint(recipient, amount);
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let _sender = get_caller_address();
            assert(_sender.is_non_zero(), 'ERC20: transfer from 0');
            assert(recipient.is_non_zero(), 'ERC20: transfer to 0');
            let _balance = self._balances.read(_sender);
            assert(_balance >= amount, 'not enough token');
            self._balances.write(_sender, self._balances.read(_sender) - amount);
            self._balances.write(recipient, self._balances.read(recipient) + amount);
        }

        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            self._balances.read(account)
        }
    }
}