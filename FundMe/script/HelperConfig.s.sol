// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

    NetworkConfig public activeNetworkConfig;

    uint8 private constant DECIMALS = 8;
    int256 private constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() private pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getMainnetEthConfig() private pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x5147eA642CAEF7BD9c1265AadcA78f997AbB9649
        });
    }

    function getOrCreateAnvilEthConfig() private returns (NetworkConfig memory) {
        // Only deploy if not yet created
        if (activeNetworkConfig.priceFeed != address(0)) { return activeNetworkConfig; }

        // Deploy a mock to the Anvil network
        vm.startBroadcast();
        MockV3Aggregator mv3a = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        return NetworkConfig({
            priceFeed: address(mv3a) 
        });
    }
}