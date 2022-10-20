// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/GatekeeperOne.sol";
import "src/levels/GatekeeperOneFactory.sol";

contract TestGatekeeperOne is BaseTest {
    GatekeeperOne private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new GatekeeperOneFactory();
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
        level = GatekeeperOne(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.entrant(), address(0));
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player, player);

        // To solve this challenge, we need to successfully call the enter fn, enter fn has three fn modifiers

        // To pass gateOne modifier, we need to call the enter fn from a smart contract, doing so
        // will allow us to pass the require check "tx.origin != msg.sender"

        // To pass gateTwo modifier, we need to make sure that the gasLeft when the require check is executed
        // is a multiple of 8191. We can make find it out by brute forcing.

        // To pass gateThree modifier, we need to know how castin works in solidity.
        // When you convert bytes8 to uint64, no info is lost because 8 bytes = 64 bits.
        // But when you downcast uint64 to uint32, 32 MSBs are lost and when you downcast uint64 to uint16, 48
        // MSBs are lost

        // We need to pass a gateKey such that after it's downcasted to uint32, it should be:

        // a): Equal to the value you get after downcasting it to uint16, so basically 16 LSBs of gateKey
        // should be same, and rest (16 MSBs of uint32) should be 0.

        // b): Not equal to the original value passed in enter fn, i.e. any bit from the 32 MSBs of a uint64
        // should be on

        // c): Equal to the value you get after downcasting the EOA address to uint16, i.e. 16 LSBs
        // of the gateKey, should be equal to our EOA address

        // We can pass third check of gateThree modifier if 16 LSBs or less important 2 bytes of our input
        // is same as our EOA address and if the rest of the bits are set to 0, this will also pass the first
        // check of gateThree modifier, but to pass second check we just need to turn on any bit from 32 MSBs of our uint64

        Attacker attacker = new Attacker();

        attacker.attack(level);

        assertEq(level.entrant(), player);

        vm.stopPrank();
    }
}

contract Attacker {
    function attack(GatekeeperOne _level) public {
        // 16 LSBs/ less important 2 bytes/ 4 hex character are same as our EOA address
        // Rest of the bits are 0, except bit 33, 34, 35 and 36 (for the sake of counting, consider LSB as bit #1 and not #0)
        // (which are on)
        _level.enter{gas: 802929}(0x0000000F00004543);
    }
}
