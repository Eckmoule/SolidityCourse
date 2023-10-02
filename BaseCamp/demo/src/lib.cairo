use starknet::ContractAddress;

#[starknet::interface]
trait IData<T> { // T is TContractState
    fn get_data(self: @T) -> felt252;
    fn get_external_data(self: @T, other_contract: ContractAddress) -> felt252;
    fn set_data(ref self: T, new_value: felt252);
}

#[starknet::interface]
trait OwnableTrait<T> {
    fn transfer_ownership(ref self: T, new_owner: ContractAddress);
    fn owner(self: @T) -> ContractAddress;
}

#[starknet::contract]
mod ownable {

    use starknet::{
        ContractAddress, 
        get_caller_address,
    };

    use super::{IData, OwnableTrait, IDataDispatcherTrait, IDataDispatcher}; // super permet d'importer ce qui est juste au dessus
    // On pourrait utiliser demo::IData car le projet se nomme demo (dans scarb.toml)

    #[storage]
    struct Storage {
     owner: ContractAddress,
     data: felt252,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
      OwnershipTransferred: OwnershipTransferred,  
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        #[key]
        prev_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_owner: ContractAddress) {
        self.owner.write(initial_owner);
    }

    #[external(v0)]
    impl OwnableDataImpl of IData<ContractState> {
        
        fn get_data(self: @ContractState) -> felt252{
            return self.data.read();
        }

        fn get_external_data(self: @ContractState, other_contract: ContractAddress) -> felt252{
            let dispatcher = IDataDispatcher { contract_address: other_contract };
            // On appel un autre contrat. 
            // lorsque l'on utilise un dispatcher cela utilse le storage du contrat que l'on appel
            // On peut utiliser un Librairie dispatcher pour utiliser son propre storage (et on passe le class hash à la place de l'addresse)
            let data = dispatcher.get_data(); 

            return data;
        }
        
        fn set_data(ref self: ContractState, new_value: felt252) {
            // owner_only_private(@self)
            self.only_owner();
            self.data.write(new_value);
        }
    }

    #[external(v0)]
    impl OwnableTraitImpl of OwnableTrait<ContractState> {
        fn transfer_ownership(
            ref self: ContractState,
            new_owner: ContractAddress)
        {
            self.only_owner();
            let prev_owner = self.owner.read();
            self.owner.write(new_owner);

            self.emit(OwnershipTransferred {
                prev_owner: prev_owner,
                new_owner: new_owner,
            });
        }

        fn owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }


    // // plutot que de retourner un bool on va revert la transaction si ce n'est pas bon.
    // // Cette fonction est privée (elle n'utilise pas #external(v0)) 
    // fn owner_only_private(self: @ContractState) {
    //     assert(1 == 1,  'Invalid owner');
    // }

    #[generate_trait] // Cela permet de ne pas déclarer le trait (cool pour les fonctions privées)
    impl PrivateMethods of PrivateMethodsTrait { // Permet de s'assurer que le contenu est privé. 
        fn only_owner(self: @ContractState) {
            let caller = get_caller_address(); 
            assert(caller == self.owner.read(), 'Caller is not the owner');
        }
    }

}