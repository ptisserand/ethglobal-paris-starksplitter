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

fn deploy() -> ISplitterDispatcher {
    let payees: Array<ContractAddress> = ArrayTrait::new();
    let shares: Array<u256> = ArrayTrait::new();
    let mut constructor_args: Array<felt252> = ArrayTrait::new();
    Serde::serialize(@payees, ref constructor_args);
    Serde::serialize(@shares, ref constructor_args);

    let (address, _) = deploy_syscall(
        Splitter::TEST_CLASS_HASH.try_into().unwrap(), 0, constructor_args.span(), true
    )
        .expect('DEPLOY_TK_FAILED');
    return ISplitterDispatcher { contract_address: address };
}

#[test]
#[available_gas(3000000)]
fn test_deploy_constructor() {
    let token = deploy();
    assert(token.totalReleased() == 0_u256, 'totalReleased');
    assert(token.totalShares() == 0_u256, 'totalShares');
}
