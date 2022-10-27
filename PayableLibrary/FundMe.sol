// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;  

import "./PriceConverter.sol";

contract FundMe {
    
    // This make the function of ProceConverter callable on uint256 (like myUint.getConversioRate())
    using PriceConverter for uint256;

    uint256 public minimumUSD = 50 * 10 ** 18;
    address public owner;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFound;

    // Modifier create keyword that you can use on function declaration
    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not owner");
        // This means "doing the rest of the code". It can be put before or after the code that we insert with modifier. 
        _;
    }

    constructor() {
        // Setup the owner has the address who deploy the contract. 
        // It will be the only address that can withdraw the fund. 
        owner = msg.sender;
    }

    // payable indiquate that you can send native token with the transaction 
    function fund() public payable {
        //msg.value is the amount sent with the transaction
        //1e18 is equal to 1 * 10^18 = 1000000000000000000 Wei = 1ETH => https://eth-converter.com/
        //require will reject the call if not ok. It will return the gas that has not been use (with the computation after the require keyword)
        require(msg.value.getConversionRate() >= minimumUSD, "Didn't send enough !");
        funders.push(msg.sender);
        addressToAmountFound[msg.sender] = msg.value;
    }

    // Withdraw everything and can only be use by the owner (the one that publish the contract). 
    // This is done by using the keyword onlyOwner that we create (modifier)
    function withdraw() public onlyOwner {

        for(uint256 funderIndex = 0; funderIndex < funders.length; funders.length + 1) {
            address funder = funders[funderIndex];
            addressToAmountFound[funder] = 0;
        }
        funders = new address[](0);

        // Transfer 
        // Transform address of the sender into payable to be capable of doing a transfert
        // Address(this) get the address of the contract 
        // Transfer will fail if the gas cost exceed 2300 gas and automatically revert 
        
        //payable(msg.sender).transfer(address(this).balance);

        // Send 
        // Send will fail if the gas cost exceed 2300 gas but do not automatically revert 
       
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send Fail");

        // Call 
        // Call can be use to call any function in ETH 
        // We don't call any function but use the transaction to send ETH (has a value)
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Send Fail");

       // Detail in https://solidity-by-example.org/sending-ether/
    }

    
}