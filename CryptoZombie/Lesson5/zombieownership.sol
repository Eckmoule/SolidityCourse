pragma solidity ^0.4.19;

import "./zombieattack.sol";
import "./erc721.sol";

// Les tokens sur la blockchain ether sont en réalité des contrats qui implémente un certain nombre de fonctions standards 
// transfert, balanceof, ... c'est donc simplement un contrat qui permet de savoir combien chaque address possède 
// Les tokens ERC20 correspondent plutot à des monnaies ils sont divisibles et ils sont "égaux" 0.25 de AAVE est toujours égal à 0.25 de AAVE 
// D'autres types de token existent et nottament les ERC721 qui nous intéresse ici. 
// Il ne sont ni divisibles ni interchangeables. 
// Pour nos zombies chaque zombies ne se valent pas (niveau 1 vs niveau 250)
// Il ne sont pas divisbles non plus, envoyer 0.25 d'un zombie ne veut rien dire.  


// En solidity l'heritage multiple est autorisé
contract ZombieOwnership is ZombieBattle, ERC721 {

    // Utilisé pour la méthode de transfert en deux étapes. 
    mapping (uint => address) zombieApprovals;

    // On implemente les fonctions définies par le contract ERC721

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerZombieCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return zombieToOwner[_tokenId];
    }

    // Implémentation de notre logique de transfer pour la factorisation. 
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        // On utilise les méthodes fournies par SafeMath pour éviter les débordements (max uint dépassé par exemple)
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        zombieToOwner[_tokenId] = _to;
        Transfer(_from, _to, _tokenId); // On déclenche l'évenement transfert du contrat ERC721
    }

    // Un transfert peut se faire en une étape vie transfer lorsque le propriétaire appel la méthode et transfert au nouveau propriétaire
    // Ou en deux étapes avec approve ou le propriétaire donne l'adresse du nouveau proprietaire puis takeOwnership ou le nouveau propriétaire vient "claim" sont du. 

    // On s'assure que seul le propriétaire du zombie peut le transférer via le modifier onlyOwnerOf
    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    // On s'assure que seul le propriétaire du zombie peut le "preparer à un transfert" via le modifier onlyOwnerOf
    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _to;
        Approval(msg.sender, _to, _tokenId); // On déclenche l'évenement appoval du contrat ERC721
    }

    function takeOwnership(uint256 _tokenId) public {
        require(zombieApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }
}
