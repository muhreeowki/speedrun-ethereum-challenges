// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	ExampleExternalContract public exampleExternalContract;

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	// Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
	// (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
	mapping(address => uint256) public balances; // Mapping of user balances
	uint256 public constant threshold = 1 ether; // 1 ETH
	uint256 public deadline = block.timestamp + 72 hours; // Deadline
	bool public openForWithdraw = true; // Open for withdraw

	// Stake event
	event Stake(address user, uint256 amount);

	// Modifiers
	modifier notCompleted() {
		require(
			exampleExternalContract.completed() == false,
			"Contract has been completed"
		);
		_;
	}

	// Stake function
	function stake() public payable {
		balances[msg.sender] += msg.value; // Update user balance
		emit Stake(msg.sender, msg.value); // Emit Stake event
	}

	// After some `deadline` allow anyone to call an `execute()` function
	// If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
	function execute() public notCompleted {
		if (address(this).balance > threshold && block.timestamp >= deadline) {
			exampleExternalContract.complete{ value: address(this).balance }();
		}
	}

	// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
	function withdraw() public notCompleted {
		if (openForWithdraw) {
			uint256 amount = balances[msg.sender];
			balances[msg.sender] = 0;
			(bool sent, ) = payable(msg.sender).call{ value: amount }("");
			require(sent, "Failed to withdraw Ether");
		}
	}

	// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
	function timeLeft() public view returns (uint256) {
		if (block.timestamp >= deadline) {
			return 0;
		} else {
			return deadline - block.timestamp;
		}
	}

	// Add the `receive()` special function that receives eth and calls stake()
	receive() external payable {
		this.stake{ value: msg.value }();
	}
}
