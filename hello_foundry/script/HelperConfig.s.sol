// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

 contract HelperConfig is Script{

NetworkConfig public activeNetworkConfig;
uint8 public constant DECIMAL = 8;
int256 public constant INITIAL_PRICE = 2000e8; 

struct NetworkConfig {
    address priceFeed;
}

constructor(){
    if(block.chainid == 11155111){
        activeNetworkConfig = sepliaConfig();
    } else if (block.chainid == 1){
        activeNetworkConfig = ethConfig();

    } else{
        activeNetworkConfig = getOrCreateAnvilConfig();
    }
}


    function sepliaConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory s_config = NetworkConfig ({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return s_config;
    }

    function ethConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory eth_config = NetworkConfig ({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return eth_config;
    }

    function getOrCreateAnvilConfig() public returns(NetworkConfig memory){
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMAL, INITIAL_PRICE);
        vm.stopBroadcast();

         NetworkConfig memory a_config = NetworkConfig ({
            priceFeed: address(mockPriceFeed)
        });
        
        return a_config;
    }
 }