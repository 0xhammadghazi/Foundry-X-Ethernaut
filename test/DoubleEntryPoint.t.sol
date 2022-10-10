// SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

import "./utils/BaseTest.sol";
import "src/levels/DoubleEntryPoint.sol";
import "src/levels/DoubleEntryPointFactory.sol";

contract TestDoubleEntryPoint is BaseTest {
    DoubleEntryPoint private level;

    constructor() public {
        // SETUP LEVEL FACTORY
        levelFactory = new DoubleEntryPointFactory();
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
        level = DoubleEntryPoint(levelAddress);
    }

    function exploitLevel() internal override {
        /** CODE YOUR EXPLOIT HERE */

        vm.startPrank(player);

        // Bug in crypto vault contract is that anyone can sweep DET token of crypto vault contract by passing Legacy token
        // address as param to sweepToken() because LegacyToken transfer function transfers
        // DET token if delegate variable (which is DET contract address) is set in LegacyToken contract.

        // Whenever someone transfers DET token, notify fn of Forta contract is called
        // which makes an external call to handleTransaction fn, this is where we can prevent
        // the transfer of DET token if the call is coming from crypto vault contract and the called function
        // is delegateTransfer. We can only do this by creating our own smart contract, writing implementaion of
        // handleTransaction fn and raising alert (if caller is cryptoVault and called function is delegateTransfer)

        DetectionBot detectionBot = new DetectionBot(
            address(level.cryptoVault()),
            address(level.forta()),
            abi.encodeWithSignature("delegateTransfer(address,uint256,address)")
        );
        level.forta().setDetectionBot(address(detectionBot));

        vm.stopPrank();
    }
}

contract DetectionBot is IDetectionBot {
    Forta public forta;
    address public cryptoVault;
    bytes public monitoredSig;

    constructor(
        address _cryptoVault,
        address _forta,
        bytes memory _monitoredSig
    ) public {
        forta = Forta(_forta);
        cryptoVault = _cryptoVault;
        monitoredSig = _monitoredSig;
    }

    function handleTransaction(address user, bytes calldata msgData) external override {
        (address to, uint256 value, address origSender) = abi.decode(msgData[4:], (address, uint256, address));
        bytes memory callSig = abi.encodePacked(msgData[0], msgData[1], msgData[2], msgData[3]);

        if (origSender == cryptoVault && keccak256(callSig) == keccak256(monitoredSig)) forta.raiseAlert(user);
    }
}
