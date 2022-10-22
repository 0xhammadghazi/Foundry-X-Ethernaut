// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./base/Level.sol";
import "./Motorbike.sol";

contract MotorbikeFactory is Level {
    function createInstance(address _player) public payable override returns (address) {
        // deploy the Engine contract
        Engine engine = new Engine();
        return address(new Motorbike(address(engine)));
    }

    function validateInstance(address payable _instance, address _player) public override returns (bool) {
        // Motorbike instance = Motorbike(_instance);
        // uint256 size;
        // assembly {
        //     size := extcodesize(instance)
        // }
        // return size == 0;
        return true;
    }
}
