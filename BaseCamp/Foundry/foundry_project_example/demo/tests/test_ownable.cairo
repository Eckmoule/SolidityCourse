
use starknet::{ContractAddress, Into, TryInto, OptionTrait};
use result::ResultTrait;
use array::{ArrayTrait, SpanTrait};
use demo::{OwnableTraitDispatcher, OwnableTraitDispatcherTrait};
use demo::{IDataSafeDispatcher, IDataSafeDispatcherTrait};

use snforge_std::{declare, ContractClassTrait};
use snforge_std::io::{FileTrait, read_txt};
use snforge_std::{start_prank, stop_prank};
use snforge_std::{start_mock_call, stop_mock_call}; 

mod Accounts {

    use traits::TryInto;    
    use starknet::{ContractAddress};

    fn admin() -> ContractAddress {
        return 'admin'.try_into().unwrap(); 
    }

    fn new_admin() -> ContractAddress {
        return 'new_admin'.try_into().unwrap(); 
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

#[test]
fn test_transfer_ownership_admin() {
    let contract_address = deploy_contract('ownable');
    let dispatcher = OwnableTraitDispatcher { contract_address }; 

    // Cheat code pour changer la valeur de l'appelant. 
    start_prank(contract_address, Accounts::admin());

    dispatcher.transfer_ownership(Accounts::new_admin());

    assert(dispatcher.owner() == Accounts::new_admin(), 'Caller is not the owner');
}

#[test]
#[should_panic(expected: ('Caller is not the owner', ))]
fn test_transfer_ownership_bad_guy() {
    let contract_address = deploy_contract('ownable');
    let dispatcher = OwnableTraitDispatcher { contract_address }; 

    // Cheat code pour changer la valeur de l'appelant. 
    start_prank(contract_address, Accounts::bad_guy());

    dispatcher.transfer_ownership(Accounts::new_admin());

    assert(dispatcher.owner() == Accounts::new_admin(), 'Caller is not the owner');
}

#[test]
fn test_data_mock_get_data() {
    let contract_address = deploy_contract('ownable');
    // Les interfaces générent des dispatcher mais également des safe dispatcher les appels retrouneront une option. 
    let safe_dispatcher = IDataSafeDispatcher { contract_address }; 

    let mock_reck_data = 100; 
    // On indique que cette méthode doit retourner la valeur donné tant que l'on a pas stopé le mock. 
    start_mock_call(contract_address, 'get_data', mock_reck_data);
    
    // On indique que les appels à ce contrat se font comme si nous étions l'admin. 
    start_prank(contract_address, Accounts::admin());
    safe_dispatcher.set_data(20); 

    // C'est un safe dispatcher donc on unwrap. 
    let data = safe_dispatcher.get_data().unwrap();
    // ON doit recevoir la valeur mocker et non ce que l'on a set. 
    assert(data == mock_reck_data, 'Should have been mock');

    stop_mock_call(contract_address, 'get_data');

    // On a stopper le mock on doit donc recevoir la valeur que nous avions set. 
    let data = safe_dispatcher.get_data().unwrap();
    assert(data == 20, 'Should have been unmock');

    stop_prank(contract_address); 
}