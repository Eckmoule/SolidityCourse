
use starknet::{ContractAddress, Into, TryInto, OptionTrait};
use result::ResultTrait;
use array::{ArrayTrait, SpanTrait};
use demo::{OwnableTraitDispatcher, OwnableTraitDispatcherTrait};

use snforge_std::{declare, ContractClassTrait};
use snforge_std::io::{FileTrait, read_txt};

mod Accounts {

    use traits::TryInto;    
    use starknet::{ContractAddress};

    fn admin() -> ContractAddress {
        return 'admin'.try_into().unwrap(); 
    }

    fn bad_guy() -> ContractAddress {
        return 'bad_guy'.try_into().unwrap(); 
    }
}

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);

    // On utilise into car on attends un felt252. 
    // let account: ContractAddress = Accounts::admin();
    // let mut calldata = array![account.into()];
    
    let file = FileTrait::new('data/calldata.txt');
    let calldata = read_txt(@file);

    return contract.deploy(@calldata).unwrap();
}

#[test]
fn test_construct_with_admin() {
    let contract_address = deploy_contract('ownable');
    
    let dispatcher = OwnableTraitDispatcher { contract_address }; 
    let owner = dispatcher.owner();

    assert(Accounts::admin() == owner, 'Not the owner');
}