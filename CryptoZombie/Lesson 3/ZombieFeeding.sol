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

  KittyInterface kittyContract;

  // On utilise le modifier onlyOwner fournit par ownable.sol (hériter depuis ZombieFactory)
  // Un modifier permet d'éxécuter du code avant chaque fonction et ici de n'autoriser l'accès qu'au owner du contrat (celui qui l'a déployé)
  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  // La nomemclature storage permet de passer un pointeur vers la structure dans le storage 
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

  // La nomemclature storage permet de passer un pointeur vers la structure dans le storage 
  function _isReady(Zombie storage _zombie) internal view returns(bool){
    // vérifie si le readyTime est passé et donc si le zombie peut effectuer une action
    return (_zombie.readyTime <= now); 
  }

  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal {
      require(msg.sender == zombieToOwner[_zombieId]); // On vérifie qu'on est bien le propriétaire du zombie
      Zombie storage myZombie = zombies[_zombieId]; // On récupére un pointeur vers le zombie concerné. Le mot clef memory aurait créé un nouvel objet en mémoire. 
      require(_isReady(myZombie)); // On s'assure que le zombie a passer son temps d'attente avant de faire une action. 
      _targetDna = _targetDna % dnaModulus; // On s'assure que ce n'est pas supérieur à 16 chiffres
      uint newDna = (myZombie.dna + _targetDna) / 2; 
      if(keccak256(_species) == keccak256("kitty")){
        // On cherche à ce que les deux derniers chiffres soient 99 si ça provient d'un chat. 
        // Si newDna est 334455. Alors newDna % 100 est 55, donc newDna - newDna % 100 est 334400. Enfin on ajoute 99 pour avoir 334499.
        newDna = newDna - newDna % 100 + 99;
      }
      _createZombie("NoName", newDna); // On créé un nouveau zombie avec un ADN correspondant à la moyenne du mangeur et du mangé. 
      _triggerCooldown(myZombie); // On réinitialise le compteur de temps d'attente avant la prochaine action. 
    }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    // En solidity on peut retourner plus de 1 variables. Ici on ne veut que la dernière : genes
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}
