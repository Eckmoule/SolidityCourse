pragma solidity ^0.4.19;

import "./zombiefactory.sol";

// Déclaration d'une interface pour intérargir avec un contrat existant. 
contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  KittyInterface kittyContract = KittyInterface(ckAddress);

  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) public {
      require(msg.sender == zombieToOwner[_zombieId]); // On vérifie qu'on est bien le propriétaire du zombie
      Zombie storage myZombie = zombies[_zombieId]; // On récupére un pointeur vers le zombie concerné. Le mot clef memory aurait créé un nouvel objet en mémoire. 
      _targetDna = _targetDna % dnaModulus; // On s'assure que ce n'est pas supérieur à 16 chiffres
      uint newDna = (myZombie.dna + _targetDna) / 2; 
      if(keccak256(_species) == keccak256("kitty")){
        // On cherche à ce que les deux derniers chiffres soient 99 si ça provient d'un chat. 
        // Si newDna est 334455. Alors newDna % 100 est 55, donc newDna - newDna % 100 est 334400. Enfin on ajoute 99 pour avoir 334499.
        newDna = newDna - newDna % 100 + 99;
      }
      _createZombie("NoName", newDna); // On créé un nouveau zombie avec un ADN correspondant à la moyenne du mangeur et du mangé. 
    }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    // En solidity on peut retourner plus de 1 variables. Ici on ne veut que la dernière : genes
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}
