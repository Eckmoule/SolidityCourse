pragma solidity ^0.4.19;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

    // Un modifier peut prendre des arguments
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _; // Cette ligne permet d'éxécuter la suite de la fonction appelante (comme base();)
    }

    // On permet de changer le nom lorsque le niveau du zombie est supérieur ou égal à 2 grace au modifier
    function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]); // On s'assure que le zombie appartient à la personne qui fait la transaction
        zombies[_zombieId].name = _newName;
    }

    // On permet de changer l'ADN lorsque le niveau du zombie est supérieur ou égal à 20 grace au modifier
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]); // On s'assure que le zombie appartient à la personne qui fait la transaction
        zombies[_zombieId].dna = _newDna;
    }

    // Les fonction view ne coutent pas de gas lorsqu'elle sont appelé de l'extérieur car elle ne font que lire la blockchain. 
    // web3.js a seulement besoin d'interroger le nœud local d'Ethereum pour faire marcher la fonction, il n'a pas besoin de créer une transaction sur la blockchain (qui devra être exécuter sur tous les nœuds et qui coûtera du gas).
    // Une view appeler par une autre fonction consommera en revanche du gas car une transaction sera réalisée.
    function getZombiesByOwner(address _owner) external view returns(uint[]) {
        // Créér un tableau en mémoire est gratuit au sens gas contrairement à l'utilisation du storage (stocké sur la blockchain). 
        // Par moment cela peut impliquer une logique de programmation qui à l'air inefficace - comme reconstruire un tableau dans la memory à chaque fois que la fonction est appelée au lieu de sauvegarder ce tableau comme une variable afin de le retrouver rapidement.
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        // On parcours la liste des zombieToOwner pour retrouver tout ceux qui appartiennent à l'address donné et on remplit le tableau qui sera retourné. 
        for(uint i = 0; i < zombies.length; i++) {
            if(zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}
