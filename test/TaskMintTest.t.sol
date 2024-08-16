// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {TaskMint} from "../src/TaskMint.sol";

contract TaskMintTest is Test {
    TaskMint private taskMint;
    address private owner = address(1);
    address private user = address(2);

    function setUp() public {
        taskMint = new TaskMint();
        vm.deal(owner, 1 ether);
        vm.deal(user, 1 ether);
    }

    function testCreateTask() public {
        vm.prank(owner);
        taskMint.createTask("Task 1");
        assertEq(taskMint.getTaskCount(), 1);
    }

    function testDepositFunds() public {
        vm.prank(owner);
        taskMint.depositFunds{value: 0.001 ether}();
        assertEq(taskMint.getDepositAmount(), 0.001 ether);
    }

    function testWithdrawDepositSafely() public {
        vm.prank(owner);
        taskMint.depositFunds{value: 0.001 ether}();
        uint256 initialBalance = owner.balance;
        taskMint.withdrawDepositSafely();
        assertEq(taskMint.getDepositAmount(), 0);
        assertEq(owner.balance, initialBalance + 0.001 ether);
    }

    function testCompleteTask() public {
        vm.prank(owner);
        taskMint.createTask("Task 1");
        taskMint.createTask("Task 2");
        taskMint.depositFunds{value: 0.001 ether}();
        taskMint.completeTask(0);
        assertEq(taskMint.getTaskCount(), 2);
        taskMint.completeTask(1);
        assertEq(taskMint.getTaskCount(), 0);
        assertEq(taskMint.getDepositAmount(), 0);
    }

    function testRevertNonExistentTask() public {
        vm.prank(owner);
        vm.expectRevert("Task does not exist");
        taskMint.completeTask(0);
    }

    function testRevertTaskAlreadyCompleted() public {
        vm.prank(owner);
        taskMint.createTask("Task 1");
        taskMint.completeTask(0);
        vm.expectRevert("Task is already completed");
        taskMint.completeTask(0);
    }

    function testRevertDepositZeroValue() public {
        vm.prank(owner);
        vm.expectRevert("You need to send some ether");
        taskMint.depositFunds{value: 0}();
    }

    function testRevertWithdrawNoFunds() public {
        vm.prank(owner);
        vm.expectRevert("There are no funds to withdraw");
        taskMint.withdrawDepositSafely();
    }
}
