// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/token/ERC20/ERC20.sol";

// question: is "god" bound by balances of addresses?

contract GodToken is ERC20 {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "E1");
        _;
    }

    constructor() ERC20("GOD TOKEN", "GOD") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
        owner = msg.sender;
    }

    function godTransfer(address from, address to, uint256 amount) external onlyOwner {
        require(msg.sender == owner, "E1");
        _transfer(from, to, amount);
    }
}
