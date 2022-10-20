// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Recovery.sol";
import "src/levels/RecoveryFactory.sol";

contract TestRecovery is BaseTest {
    Recovery private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new RecoveryFactory();
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
        level = Recovery(levelAddress);

        // Check that the contract is correctly setup
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        // We can recover the funds by calling destroy fn of SimpleToken contract if we know the address of
        // SimpleToken contract

        // We can find address of the lost SimpleToken contract by looking at the txn that have called generateToken fn

        // To solve this problem without hardcoding the address, I googled how a smart contract address is computed
        // and found this article: https://ethereum.stackexchange.com/questions/760/how-is-the-address-of-an-ethereum-contract-computed/761

        vm.startPrank(player, player);

        address payable contractAddress = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(level), bytes1(0x01)))))
        );

        SimpleToken(contractAddress).destroy(player);

        vm.stopPrank();
    }
}
