// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/token/ERC20/ERC20.sol";

// question: to use openzeppelin AC or to implement own?

// question: what are all the "chokepoints" we need to consider to enforce the sanctions? Should approvals be prohibited as well?

// question: how to properly use "Error" in solidity?

contract SanctionedToken is ERC20 {
    address public owner;
    mapping(address => bool) public sanctioned;

    modifier onlyOwner() {
        require(msg.sender == owner, "E1");
        _;
    }

    constructor() ERC20("SanctionedToken", "SANCT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
        owner = msg.sender;
    }

    function ban(address _account) external onlyOwner {
        sanctioned[_account] = true;
    }

    function unban(address _account) external onlyOwner {
        sanctioned[_account] = false;
    }

    function batchBan(address[] calldata _accounts) external onlyOwner {
        for (uint256 i = 0; i < _accounts.length; i++) {
            sanctioned[_accounts[i]] = true;
        }
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        require(!sanctioned[from], "E2");
        require(!sanctioned[to], "E3");
        super._transfer(from, to, amount);
    }
}
