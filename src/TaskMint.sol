// Address of the contract: 0x21750a59CFD663B78b065DA9e6C76BA44c2bc525
/*
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TaskMint {
    struct Task {
        string description;
        bool isCompleted;
    }

    Task[] public tasks;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTask(string memory _description) public onlyOwner {
        tasks.push(Task(_description, false));
    }

    function depositFunds() public payable onlyOwner {
        require(msg.value > 0, "You need to send some ether");
    }

    function withdrawDepositSafely() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "There are no funds to withdraw");
        payable(owner).transfer(amount);
    }

    function allTasksCompleted() private view returns (bool) {
        for (uint256 i = 0; i < tasks.length; i++) {
            if (!tasks[i].isCompleted) {
                return false;
            }
        }
        return true;
    }

    function clearTask() private {
        delete tasks;
    }

    function completeTask(uint256 _taskId) public onlyOwner {
        require(_taskId < tasks.length, "Task does not exist");
        require(!tasks[_taskId].isCompleted, "Task is already completed");

        tasks[_taskId].isCompleted = true;

        if (allTasksCompleted()) {
            uint256 amount = address(this).balance;
            payable(owner).transfer(amount);
            clearTask();
        }
    }

    function getTaskCount() public view returns (uint256) {
        return tasks.length;
    }

    function getDepositAmount() public view returns (uint256) {
        return address(this).balance;
    }

    function getTasks() public view returns (Task[] memory) {
        return tasks;
    }
}
*/

// Refactored Version

pragma solidity ^0.8.19;

contract TaskMint {
    struct Task {
        string description;
        bool isCompleted;
    }

    Task[] public tasks;
    address public immutable owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTask(string memory _description) external onlyOwner {
        tasks.push(Task({description: _description, isCompleted: false}));
    }

    function depositFunds() external payable onlyOwner {
        require(msg.value > 0, "You need to send some ether");
    }

    function withdrawDepositSafely() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "There are no funds to withdraw");
        payable(owner).transfer(balance);
    }

    function completeTask(uint256 _taskId) external onlyOwner {
        require(_taskId < tasks.length, "Task does not exist");
        require(!tasks[_taskId].isCompleted, "Task is already completed");

        tasks[_taskId].isCompleted = true;

        if (_allTasksCompleted()) {
            _withdrawAndClear();
        }
    }

    function getTaskCount() external view returns (uint256) {
        return tasks.length;
    }

    function getDepositAmount() external view returns (uint256) {
        return address(this).balance;
    }

    function getTasks() external view returns (Task[] memory) {
        return tasks;
    }

    // Private Functions

    function _allTasksCompleted() private view returns (bool) {
        for (uint256 i = 0; i < tasks.length; i++) {
            if (!tasks[i].isCompleted) {
                return false;
            }
        }
        return true;
    }

    function _withdrawAndClear() private {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(owner).transfer(balance);
        }
        delete tasks;
    }
}
