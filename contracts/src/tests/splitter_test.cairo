use array::ArrayTrait;
use debug::PrintTrait;
use starknet::{
    get_contract_address, deploy_syscall, ClassHash, contract_address_const, ContractAddress,
};
use starknet::class_hash::Felt252TryIntoClassHash;
use starknet::testing::{set_contract_address, set_block_timestamp};
use traits::{TryInto};

use result::{Result, ResultTrait};
use option::{OptionTrait};

use splitter::splitter::{ISplitterDispatcher, ISplitterDispatcherTrait, Splitter};
use splitter::tests::mocks::erc20::{IERC20Dispatcher, IERC20DispatcherTrait, ERC20};

fn deploy_default() -> ISplitterDispatcher {
    let token_address = deploy_erc20();
    let mut payees: Array<ContractAddress> = ArrayTrait::new();
    let mut shares: Array<u256> = ArrayTrait::new();
    payees.append(contract_address_const::<1>());
    shares.append(10_u256);
    payees.append(contract_address_const::<2>());
    shares.append(20_u256);
    deploy(token_address, payees, shares, 300_u256)
}

fn deploy(token_address: ContractAddress, payees: Array<ContractAddress>, shares: Array<u256>, amount: u256) -> ISplitterDispatcher {

    let mut constructor_args: Array<felt252> = ArrayTrait::new();
    Serde::serialize(@token_address, ref constructor_args);
    Serde::serialize(@payees, ref constructor_args);
    Serde::serialize(@shares, ref constructor_args);

    let (address, _) = deploy_syscall(
        Splitter::TEST_CLASS_HASH.try_into().unwrap(), 0, constructor_args.span(), true
    )
        .expect('DEPLOY_TK_FAILED');
    let erc20 = IERC20Dispatcher { contract_address: token_address};
    erc20.mint(address, amount);
    return ISplitterDispatcher { contract_address: address };
}

fn deploy_erc20() -> ContractAddress {
    let mut constructor_args: Array<felt252> = ArrayTrait::new();

    let (address, _) = deploy_syscall(
        ERC20::TEST_CLASS_HASH.try_into().unwrap(), 0, constructor_args.span(), true
    )
        .expect('DEPLOY_TK_FAILED');
    address
}

#[test]
#[available_gas(3000000)]
fn test_deploy_erc20() {
    let _address = deploy_erc20();
    let erc20 = IERC20Dispatcher { contract_address: _address};
    let account = contract_address_const::<6>();
    erc20.mint(account, 30_u256);
    assert(erc20.balanceOf(account) == 30_u256, 'mint failed');
}
#[test]
#[available_gas(3000000)]
fn test_deploy_constructor() {
    let splitter = deploy_default();
    assert(splitter.totalReleased() == 0_u256, 'totalReleased');
    assert(splitter.totalShares() == 30_u256, 'totalShares');
}

#[test]
#[available_gas(3000000)]
fn test_deploy_constructor_shares() {
    let splitter = deploy_default();
    assert(splitter.totalShares() == 30_u256, 'totalShares');
    assert(splitter.shares(contract_address_const::<1>()) == 10_u256, 'account 1 shares');
    assert(splitter.shares(contract_address_const::<2>()) == 20_u256, 'account 2 shares');
}

#[test]
#[available_gas(3000000)]
fn test_shares_for_unknown_contract() {
    let splitter = deploy_default();
    assert(splitter.shares(contract_address_const::<22>()) == 0, 'shares unknown contract');
}

#[test]
#[available_gas(3000000)]
fn test_released_for_unknown_contract() {
    let splitter = deploy_default();
    assert(splitter.released(contract_address_const::<22>()) == 0, 'released unknown contract');
}

#[test]
#[available_gas(3000000)]
#[should_panic]
fn test_release_for_unknown_contract() {
    let splitter = deploy_default();
    splitter.release(contract_address_const::<22>());
}

#[test]
#[available_gas(3000000)]
fn test_release() {
    let splitter = deploy_default();
    let account = contract_address_const::<2>();
    assert(splitter.release(account) == true, 'release');

}