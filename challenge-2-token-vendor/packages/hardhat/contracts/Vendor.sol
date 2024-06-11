pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	// Events
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);
	// State variables
	YourToken public yourToken;

	// Constants
	uint256 public constant tokensPerEth = 100; // Token price: 1 ETH = 100 tokens

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	// ToDo: create a payable buyTokens() function:
	function buyTokens() public payable {
		uint256 amountOfTokens = msg.value * tokensPerEth; // Calculate the amount of tokens to be sent
		yourToken.transfer(msg.sender, amountOfTokens); // Send the tokens to the user
		emit BuyTokens(msg.sender, msg.value, amountOfTokens);
	}

	// ToDo: create a withdraw() function that lets the owner withdraw ETH
	function withdraw() public onlyOwner {
		(bool success, ) = payable(owner()).call{
			value: address(this).balance
		}(""); // Send the ETH to the owner
		require(success, "Withdraw failed.");
	}

	// ToDo: create a sellTokens(uint256 _amount) function:
	function sellTokens(uint256 amount) public {
		yourToken.transferFrom(msg.sender, address(this), amount); // Transfer tokens from the user to the Vendor
		uint256 amountOfETH = amount / tokensPerEth; // Amount of ETH to be sent to the user
		(bool success, ) = payable(msg.sender).call{ value: amountOfETH }(""); // Send the ETH to the user
		require(success, "Transfer failed.");
		emit SellTokens(msg.sender, amount, amountOfETH);
	}
}
