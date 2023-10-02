// SPDX-License-Identifier: MIT 
pragma solidity 0.8.8; 

contract SimpleStorage {
    bool hasFavoriteNumber = true; 
    uint256 favoriteNumber = 5; // uint is only positive number 
    int256 favoriteInt = -5; // int can have negative number 
    string favoriteNumberText = "Five";
    bytes32 favoriteNumberByte = "cat";
    address myAdress = 0xDE275C86365a1Dc0493aF77FD98f32C40892512b;

    uint256 public fav;

    function store(uint256 _fav) public {
        fav = _fav;
    }

    // view keyword create a function that does not consume gas but can only retrieve information (no writing)
    // If this is call from a contract it will cost gas.
    function retrieve() view public returns(uint256) {
        return fav;
    }

    // pure keyword create a function that does not consume gas but can't interact with the blockchain (read/write)
    // That can be use for calculation helper for example
    function add() pure public returns(uint256) {
        return (1 + 1);
    }

    struct People {
        uint256 fav;
        string name;
    }

    // People public person = People({fav: 2, name: "Yohan"});
    People[] public personList;
    mapping(string => uint256) public nameToFavoriteNumber;


    // Data need to be stored somewhere. 
    // 1. calldata: Temporary variable that can't be modify
    // 2. memory: Temporary variable that can be modify 
    // 3. storage: Permanent variable that can be modify 
    // This is only mandatory for arrays, struct and mapping type. string is an array 
    function addPerson(string calldata _name, uint256 _fav) public {
        personList.push(People(_fav, _name));
        nameToFavoriteNumber[_name] = _fav;
    }


    
}