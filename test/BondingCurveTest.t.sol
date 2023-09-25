// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/BondingCurve.sol";
import "openzeppelin/utils/math/Math.sol";

// question: best way to test the invariant y = x^2 ?

contract BondingCurveTest is Test {
    BondingCurve bondingCurve;

    uint256 ETH_RESERVE = 1_000_000_000_000;
    uint256 TOKEN_SUPPLY = 1_000_000;

    uint256 MAX_RESERVE = 1e7 ether;
    uint256 MAX_ETH_IN = 1e6 ether;

    uint256 ETH_IN = 1 ether;

    function setUp() public {
        bondingCurve = new BondingCurve();
    }

    function testPurchase() public {
        _purchase(ETH_IN, Math.sqrt(ETH_IN));
        assert(bondingCurve.balanceOf(address(this)) == Math.sqrt(ETH_IN));
    }

    function testSlippage() public {
        vm.expectRevert(bytes("E1"));
        _purchase(ETH_IN, Math.sqrt(ETH_IN) + 1);
    }

    function testSequentialActions() public {

    }

    /* -------------------------------------------------------------------- */

    function _purchase(uint256 ethIn, uint256 minTokenOut) internal {
        bondingCurve.purchaseTokens{value: ethIn}(minTokenOut);
    }

    function _sell(uint256 minEthOut, uint256 amountToSell) internal {
        bondingCurve.sellTokens(minEthOut, amountToSell);
    }

}
