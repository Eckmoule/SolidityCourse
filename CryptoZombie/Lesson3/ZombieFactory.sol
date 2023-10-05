pragma solidity ^0.4.19;

import "./ownable.sol";

contract ZombieFactory is Ownable {

    // Permet de déclencher un évenement dans le front-end
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    // Solidity offre des unité de temps minutes, hours & days exprimées en secondes (1 hours = 3600) 
    uint cooldownTime = 1 days;

    struct Zombie {
        string name;
        uint dna;
        // Utiliser des uint32 à la place de uint (uint256 par défaut) permet d'économiser de l'espace de stockage et donc du gas 
        // En effet solidity est capable de grouper des données dans un meme espace de 256 bits. 
        // Pour cela il est nécessaire de les regrouper (elles doivent se suivre) au sein d'une structure.  
        uint32 level;
        uint32 readyTime;
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    // le mot clef internal permet l'appel depuis les classes filles contrairement à private. 
    function _createZombie(string _name, uint _dna) internal {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}
