// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/utils/math/Math.sol";
import "openzeppelin/token/ERC20/ERC20.sol";

// question: what's the best practice for return values of external/public functions?
// must they all have a return value (bool success)? or can they return nothing?

// question: consensus on using custom errors?

// question: should there be any trace of front-end requirements in the smart contract?

contract BondingCurve is ERC20 {
    uint256 public ethReserve;
    uint256 public tokenSupply;

    constructor() ERC20("Bonding Curve", "BCR") {}

    /// @notice Returns the current price of tokens in ETH.
    /// @dev Price = 2 * token supply (increases linearly with supply)
    function getCurrentPrice() external view returns (uint256) {
        return tokenSupply << 1;
    }

    /// @notice Mints tokens to the sender in exchange for ETH.
    /// @param _minTokensOut Minimum amount of tokens the sender expects to receive.
    function purchaseTokens(uint256 _minTokensOut) external payable {
        uint256 tokenOut = _calculateTokenOut(msg.value);
        require(tokenOut >= _minTokensOut, "E1");
        ethReserve += msg.value;
        tokenSupply += tokenOut;
        _mint(msg.sender, tokenOut);
    }

    /// @notice Burns tokens from the sender in exchange for ETH.
    /// @param _minEthOut Minimum amount of ETH the sender expects to receive.
    /// @param _amountToSell Amount of tokens the sender wants to sell.
    function sellTokens(uint256 _minEthOut, uint256 _amountToSell) external {
        require(_amountToSell <= balanceOf(msg.sender), "E2");
        uint256 ethOut = _calculateEthOut(_amountToSell);
        require(ethOut >= _minEthOut, "E3");
        ethReserve -= ethOut;
        tokenSupply -= _amountToSell;
        _burn(msg.sender, _amountToSell);
        payable(msg.sender).transfer(ethOut);
    }

    function _calculateTokenOut(uint256 ethIn) internal view returns (uint256) {
        uint256 tokenOut = Math.sqrt(ethIn + ethReserve) - Math.sqrt(ethReserve);
        return tokenOut;
    }

    function _calculateEthOut(uint256 tokenIn) internal view returns (uint256) {
        uint256 ethOut = (tokenIn ** 2) + ((tokenSupply * tokenIn) << 1);
        return ethOut;
    }
}
