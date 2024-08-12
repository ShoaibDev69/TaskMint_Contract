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
        taskMint.createTask("Task 2");
        taskMint.createTask("Task 3");

        TaskMint.Task[] memory tasks = taskMint.getTasks();
        assertEq(tasks[0].description, "Task 1");
        assertEq(tasks[1].description, "Task 2");
        assertEq(tasks[2].description, "Task 3");
        assertEq(tasks[0].isCompleted, false);
        assertEq(tasks[1].isCompleted, false);
        assertEq(tasks[2].isCompleted, false);
    }

    function testDepositFunds() public {
        taskMint.depositFunds{value: 0.001 ether}();
        assertEq(address(taskMint).balance, 0.001 ether);
    }

    function testWithdrawDepositSafely() public {
        taskMint.depositFunds{value: 0.001 ether}();
        uint256 initialBalance = address(this).balance;

        taskMint.withdrawDepositSafely();
        assertEq(address(taskMint).balance, 0);
        assertEq(address(this).balance, initialBalance + 0.001 ether);
    }

    function testCompleteTask() public {
        taskMint.createTask("Task 1");
        taskMint.createTask("Task 2");
        taskMint.createTask("Task 3");

        taskMint.depositFunds{value: 0.001 ether}();

        // Complete the first task
        taskMint.completeTask(0);
        assertEq(taskMint.getTasks()[0].isCompleted, true);
        assertEq(taskMint.getTasks()[1].isCompleted, false);
        assertEq(taskMint.getTasks()[2].isCompleted, false);
        assertEq(address(taskMint).balance, 0.001 ether);

        // Complete the remaining tasks and ensure funds are withdrawn
        taskMint.completeTask(1);
        taskMint.completeTask(2);
        assertEq(address(taskMint).balance, 0); // Funds should be withdrawn
        assertEq(taskMint.getTaskCount(), 0);    // All tasks should be cleared
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