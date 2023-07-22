use array::ArrayTrait;
use debug::PrintTrait;
use starknet::{
    get_contract_address, deploy_syscall, ClassHash, contract_address_const, ContractAddress,
};
use starknet::class_hash::Felt252TryIntoClassHash;
use starknet::testing::{set_caller_address};

use traits::{TryInto};

use result::{Result, ResultTrait};
use option::{OptionTrait};

use splitter::splitter::{ISplitterDispatcher, ISplitterDispatcherTrait, Splitter};
use splitter::tests::mocks::erc20::{IERC20Dispatcher, IERC20DispatcherTrait, ERC20};

fn alice() -> ContractAddress {
    contract_address_const::<42>()
}

fn bob() -> ContractAddress {
    contract_address_const::<43>()
}

fn jdoe() -> ContractAddress {
    contract_address_const::<4269>()
}

const shares_alice: u256 = 10_u256;
const shares_bob: u256 = 40_u256;

fn deploy_default() -> ISplitterDispatcher {
    let token_address = deploy_erc20();
    let mut payees: Array<ContractAddress> = ArrayTrait::new();
    let mut shares: Array<u256> = ArrayTrait::new();
    payees.append(alice());
    shares.append(shares_alice);
    payees.append(bob());
    shares.append(shares_bob);
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
    let account = jdoe();
    erc20.mint(account, 30_u256);
    assert(erc20.balanceOf(account) == 30_u256, 'mint failed');
    let expected_amount = erc20.balanceOf(contract_address_const::<2>());
    assert(expected_amount == 0_u256,'initial balance');
}

#[test]
#[available_gas(3000000)]
fn test_deploy_mint() {
    let token_address = deploy_erc20();
    let mut payees: Array<ContractAddress> = ArrayTrait::new();
    let mut shares: Array<u256> = ArrayTrait::new();
    payees.append(alice());
    shares.append(shares_alice);
    payees.append(bob());
    shares.append(shares_bob);
    let splitter = deploy(token_address, payees, shares, 300_u256);
    assert(splitter.token() == token_address, 'token address');
}

#[test]
#[available_gas(3000000)]
fn test_deploy_constructor() {
    let splitter = deploy_default();
    assert(splitter.totalReleased() == 0_u256, 'totalReleased');
    assert(splitter.totalShares() == (shares_alice + shares_bob), 'totalShares');
}

#[test]
#[available_gas(3000000)]
fn test_deploy_constructor_shares() {
    let splitter = deploy_default();
    assert(splitter.totalShares() == (shares_alice + shares_bob), 'totalShares');
    assert(splitter.shares(alice()) == shares_alice, 'account 1 shares');
    assert(splitter.shares(bob()) == shares_bob, 'account 2 shares');
}

#[test]
#[available_gas(3000000)]
fn test_shares_for_unknown_contract() {
    let splitter = deploy_default();
    assert(splitter.shares(jdoe()) == 0, 'shares unknown contract');
}

#[test]
#[available_gas(3000000)]
fn test_released_for_unknown_contract() {
    let splitter = deploy_default();
    assert(splitter.released(jdoe()) == 0, 'released unknown contract');
}

#[test]
#[available_gas(3000000)]
#[should_panic]
fn test_release_for_unknown_contract() {
    let splitter = deploy_default();
    splitter.release(jdoe());
}

#[test]
#[available_gas(30000000)]
fn test_release() {
    let splitter = deploy_default();
    let erc20 = IERC20Dispatcher { contract_address: splitter.token() };
    let expected_alice = 60_u256;
    let expected_bob = 240_u256;
    let expected_amount = erc20.balanceOf(alice());
    assert(expected_amount == 0_u256, 'alice should be null');
    assert(splitter.release(alice()) == true, 'release alice');
    let expected_amount = erc20.balanceOf(alice());
    assert(expected_amount == expected_alice, 'alice amount');
    let expected_amount = erc20.balanceOf(bob());
    assert(expected_amount == 0_u256, 'should be null');
    assert(splitter.released(alice()) == expected_alice, 'alice released');
    assert(splitter.totalReleased() == expected_alice, 'totalReleased');
    assert(splitter.release(bob()) == true, 'release bob');
    assert(erc20.balanceOf(bob()) == expected_bob, 'bob amount');
    assert(erc20.balanceOf(alice()) == expected_alice, 'alice amount after');
    assert(splitter.totalReleased() == (expected_alice + expected_bob), 'totalReleased');
}