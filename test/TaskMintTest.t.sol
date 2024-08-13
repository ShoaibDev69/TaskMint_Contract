// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {TaskMint} from "../src/TaskMint.sol";

contract TaskMintTest is Test {
    TaskMint private taskMint;
    address private owner;

    function setUp() public {
        owner = address(this);
        taskMint = new TaskMint();
    }

    function testCreateTask() public {
        taskMint.createTask("Task 1");
        assertEq(taskMint.getTaskCount(), 1);
        (string memory description, bool isCompleted) = taskMint.getTasks(0);
        assertEq(description, "Task 1");
        assertEq(isCompleted, false);
    }

    function testDepositFunds() public {
        taskMint.depositFunds{value: 0.001 ether}();
        assertEq(taskMint.getDepositAmount(), 0.001 ether);
    }

    function testWithdrawDepositSafely() public {
        taskMint.depositFunds{value: 0.001 ether}();
        uint256 initialBalance = address(this).balance;
        taskMint.withdrawDepositSafely();
        assertEq(taskMint.getDepositAmount(), 0);
        assertEq(address(this).balance, initialBalance + 0.001 ether);
    }

    function testCompleteTask() public {
        taskMint.createTask("Task 1");
        taskMint.createTask("Task 2");
        taskMint.depositFunds{value: 0.001 ether}();
        taskMint.completeTask(0);
        assertEq(taskMint.getTasks()[0].isCompleted, true);
        assertEq(taskMint.getTasks()[1].isCompleted, false);
        taskMint.completeTask(1);
        assertEq(taskMint.getTaskCount(), 0);
        assertEq(taskMint.getDepositAmount(), 0);
    }

    function testRevertNonExistentTask() public {
        vm.expectRevert("Task does not exist");
        taskMint.completeTask(0);
    }

    function testRevertTaskAlreadyCompleted() public {
        taskMint.createTask("Task 1");
        taskMint.completeTask(0);
        vm.expectRevert("Task is already completed");
        taskMint.completeTask(0);
    }

    function testRevertDepositZeroValue() public {
        vm.expectRevert("You need to send some ether");
        taskMint.depositFunds{value: 0}();
    }

    function testRevertWithdrawNoFunds() public {
        vm.expectRevert("There are no funds to withdraw");
        taskMint.withdrawDepositSafely();
    }
}
