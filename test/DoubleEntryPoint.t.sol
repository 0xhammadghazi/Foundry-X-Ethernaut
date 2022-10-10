// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/DoubleEntryPoint.sol";
import "src/levels/DoubleEntryPointFactory.sol";

contract TestDoubleEntryPoint is BaseTest {
    DoubleEntryPoint private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DoubleEntryPointFactory();
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
        level = DoubleEntryPoint(levelAddress);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        Forta forta = level.forta();

        Saviour saviour = new Saviour(address(forta));
        forta.setDetectionBot(address(saviour));

        vm.stopPrank();
    }
}

contract Saviour is IDetectionBot, BaseTest {
    Forta public forta;

    constructor(address _forta) public {
        forta = Forta(_forta);
    }

    function handleTransaction(address user, bytes calldata msgData) external override {
        forta.raiseAlert(user);
    }
}
