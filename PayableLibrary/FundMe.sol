// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;  

import "./PriceConverter.sol";

contract FundMe {
    
    // This make the function of ProceConverter callable on uint256 (like myUint.getConversioRate())
    using PriceConverter for uint256;

    uint256 public minimumUSD = 50 * 10 ** 18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFound;

    // payable indiquate that you can send native token with the transaction 
    function fund() public payable {
        //msg.value is the amount sent with the transaction
        //1e18 is equal to 1 * 10^18 = 1000000000000000000 Wei = 1ETH => https://eth-converter.com/
        //require will reject the call if not ok. It will return the gas that has not been use (with the computation after the require keyword)
        require(msg.value.getConversionRate() >= minimumUSD, "Didn't send enough !");
        funders.push(msg.sender);
        addressToAmountFound[msg.sender] = msg.value;
    }

    // function withdraw() {}
}