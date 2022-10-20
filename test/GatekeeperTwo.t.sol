// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/GatekeeperTwo.sol";
import "src/levels/GatekeeperTwoFactory.sol";

contract TestGatekeeperTwo is BaseTest {
    GatekeeperTwo private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new GatekeeperTwoFactory();
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
        level = GatekeeperTwo(levelAddress);

        // Check that the contract is correctly setup
        assertEq(level.entrant(), address(0));
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player, player);

        // Just like GateKeeperOne, we need to call enter fn successfully

        // Enter fn again has three fn modifiers, first one is same

        // Second fn modifier, makes sure that you can't call this fn from a smart contract, it checks that
        // the code size of the caller account is 0, to by pass this check, we can call the enter fn from the constructor
        // of our attacker contract

        // As explained by "https://github.com/StErMi/foundry-ethernaut/blob/main/test/GatekeeperTwo.t.sol"
        // A contract has two different bytes codes when compiled
        // The creation bytecode and the runtime bytecode
        // The runtime bytecode is the real code of the contract, the one stored in the blockchain
        // The creation bytecode is the bytecode needed by Ethereum to create the contract and execute the constructor only once
        // When the constructor is executed initializing the contract storage it returns the runtime bytecode
        // Until the very end of the constructor the contract itself does not have any runtime bytecode
        // So if you call address(contract).code.length it will return 0!

        // To pass gateThree modifier, we need to make sure that if we hash the caller address, downcast it to bytes8,
        // typecast it to uint64 then XOR it to the input after casting it to uint64 it should be equal to the
        // max number that a uint64 can store

        // So, basically we need to make sure that when we XOR it, each bit of the resultant uint64 should be ON.
        // We know that XOR turns ON the bit only if the input bits are different. So we need to find a GateKey which has
        // only those bits turned ON which are OFF in the result that we get when we do
        // "uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))"

        // If the bits of "uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))" & "uint64(_gateKey)" are inverse,
        // the result would be a uint64 with each bit turned ON.

        // We can find the right key by doing what our target contract is doing i.e. "uint64(bytes8(keccak256(abi.encodePacked(address(this)))))"
        // and then negating it (i.e. reversing the bits). When we do this, we get the key whose bits are inverse of
        // "uint64(bytes8(keccak256(abi.encodePacked(address(this)))))" so when we XOR them we get the max number of
        // uint64
        new Attacker(level);

        assertEq(level.entrant(), player);

        vm.stopPrank();
    }
}

contract Attacker {
    constructor(GatekeeperTwo _level) public {
        uint64 key = ~uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
        // key = 0xFE8C2E1BD1CA68F5
        _level.enter(bytes8(key));
    }
}
