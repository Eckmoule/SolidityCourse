pragma solidity ^0.4.19;

import "./zombiehelper.sol";

contract ZombieBattle is ZombieHelper {
    
    uint randNonce = 0;

    // On cherche à générer un nombre aléatoire et pour cela on va utiliser le hash du timestamp et de l'adresse de l'appelant ainsi qu'un nombre qui sera incrémenté pour éviter plusieurs meme génération. 
    // Le modulo permet de gérer la fourchette que l'on souhaite ( % 100 rendra un nombre en 0 et 99)
    // Cette fonction n'est pas réellement aléatoire et peut être exploité. La génération de nombre aléatoire est un problème complexe qui peut etre résolu en partie en utilisant des oracles. 
    function randMod(uint _modulus) internal returns (uint) {
        randNonce++;
        return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
    }

    function attack(uint _zombieId, uint _targetId) external ownerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        uint rand = randMod(100);
        if(rand <= attackVictoryProbability){
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } 
        else {
            myZombie.lossCount++;
            enemyZombie.winCount++;
        }
        _triggerCooldown(myZombie);
    }
}