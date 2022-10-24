# Ethernaut CTF solutions using foundry

[My solutions](https://github.com/hammadghazi/Foundry-X-Ethernaut/tree/main/test) of [Ethernaut CTFs](https://ethernaut.openzeppelin.com/).



## How to play

### Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
```

### Update Foundry

```bash
foundryup
```

### Clone repo, install dependencies and build

```bash
git clone https://github.com/hammadghazi/Foundry-X-Ethernaut.git
forge install
forge build
```

### Run all challenges

```bash
forge test -vv
```

### Run a specific challenge

```bash
# example forge test --match-contract TestCoinFlip
forge test --match-contract NAME_OF_THE_TEST
```

### Create your own solutions

Create a new test `CHALLENGE.t.sol` in the `test/` directory and inherit from `BaseTest.sol`.

**BaseTest.sol** will automate all these things:

1. The constructor will set up some basic parameters like the number of users to create, how many ethers give them (5 ether) as initial balance and the labels for each user (for better debugging with forge)
2. Set up the `Ethernaut` contract
3. Register the level that you have specified in your `CHALLENGE.t.sol` constructor
4. Run the test automatically calling two callbacks inside your `CHALLENGE.t.sol` contract
   - `setupLevel` is the function you must override and implement all the logic needed to set up the challenge. Usually is always the same (call `createLevelInstance` and initialize the `level` variable)
   - `exploitLevel` is the function you must override and implement all the logic to solve the challenge
5. Run automatically the `checkSuccess` function that will check if the solution you have provided has solved the challenge

Here's an example of a test

```solidity
// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import './utils/BaseTest.sol';
import 'src/levels/CHALLENGE.sol';
import 'src/levels/CHALLENGEFactory.sol';

import '@openzeppelin/contracts/math/SafeMath.sol';

contract TestCHALLENGE is BaseTest {
  CoinFlip private level;

  constructor() public {
    // SETUP LEVEL FACTORY
    levelFactory = new CHALLENGEFactory();
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
    level = CHALLENGE(levelAddress);
  }

  function exploitLevel() internal override {
    /** CODE YOUR EXPLOIT HERE */

    vm.startPrank(player);

    // SOLVE THE CHALLENGE!

    vm.stopPrank();
  }
}

```

What you need to do is to

1. Replace `CHALLENGE` with the name of the Ethernaut challenge you are solving
2. Modify `setupLevel` if needed
3. Implement the logic to solve the challenge inside `exploitLevel` between `startPrank` and `stopPrank`
4. Run the test!

## Acknowledgement

- [Template Repo](https://github.com/StErMi/foundry-ethernaut)

## Note

- [Alien Codex](https://ethernaut.openzeppelin.com/level/0xda5b3Fb76C78b6EdEE6BE8F11a1c31EcfB02b272) is not part of this repository.
- [Motorbike](https://ethernaut.openzeppelin.com/level/0x58Ab506795EC0D3bFAE4448122afa4cDE51cfdd2) challenge test case can't be validated because of the way foundry test works.
- [MagicNumber](https://ethernaut.openzeppelin.com/level/0xaCB258afa213Db8E0007459f5d3851c112d2fA8d) is not part of this repository.

