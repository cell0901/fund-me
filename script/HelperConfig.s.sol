// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // 1. deploy mocks(deploying the  fake price feed of ETH/USD address to locally test it) when we are local blockchain
    // 2. keep track off different addresses of different chains
    // if we are on local anvil node, we deploy mocks otherwise we grab addressed from live network
    networkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    struct networkConfig {
        address priceFeed; // eth/usd price feed
    }

    function getSepoliaEthConfig() public pure returns (networkConfig memory) {
        networkConfig memory sepoliaConfig = networkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (networkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            // saying if the pricefeed isnt zero address means we have already deployed the mock, so use that mock instead of redeploying it every time
            return activeNetworkConfig;
        }
        // 1. deploy the mocks
        // 2. return the mock address
        vm.startBroadcast();
        // in here we gonna deploy our own price feed
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        networkConfig memory anvilConfig = networkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
