// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address getRecentlyDeployedAddress) public {
        vm.startBroadcast();
        FundMe(payable(getRecentlyDeployedAddress)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("txm sucessful", SEND_VALUE);
    }

    function run() external {
        address getRecentlyDeployedAddress = DevOpsTools
            .get_most_recent_deployment("Fundme", block.chainid);

        fundFundMe(getRecentlyDeployedAddress);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address getRecentlyDeployedAddress) public {
        vm.startBroadcast();
        FundMe(payable(getRecentlyDeployedAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address getRecentlyDeployedAddress = DevOpsTools
            .get_most_recent_deployment("witdraw", block.chainid);

        vm.startBroadcast();
        withdrawFundMe(getRecentlyDeployedAddress);
        vm.stopBroadcast();
    }
}
