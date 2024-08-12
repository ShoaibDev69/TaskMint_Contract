// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TaskMint} from "../src/TaskMint.sol";

contract DeployTaskMint is Script {
    function run() external returns (TaskMint) {
        vm.startBroadcast();
        TaskMint taskMint = new TaskMint();
        vm.stopBroadcast();
        return taskMint;
    }
}