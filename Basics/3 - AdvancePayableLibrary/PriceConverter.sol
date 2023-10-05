// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0; 

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Library are similar to contract but you can't declare any state variable and you can't send ether.
library PriceConverter {

      function getPrice() internal view returns (uint256) {
        // Address from chainlink documentation : 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;

        return ethAmountInUsd;
    }

    function getVersion() internal view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return priceFeed.version();
    }
} 