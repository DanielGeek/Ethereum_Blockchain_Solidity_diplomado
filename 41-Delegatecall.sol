// Delegatecall

// delegatecall is a low level function similar to call.

// When contract A executes delegatecall to contract B, B's code is executed

// with contract A's storage, msg.sender and msg.value.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// NOTE: Deploy this contract first
contract B {
    // NOTE: storage layout must be the same as contract A
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract A {
    uint256 public num;
    address public sender;
    uint256 public value;

    event DelegateResponse(bool success, bytes data);
    event CallResponse(bool success, bytes data);

    // Function using delegatecall
    function setVarsDelegateCall(address _contract, uint256 _num)
        public
        payable
    {
        // A's storage is set; B's storage is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );

        emit DelegateResponse(success, data);
    }

    // Function using call
    function setVarsCall(address _contract, uint256 _num) public payable {
        // B's storage is set; A's storage is not modified.
        (bool success, bytes memory data) = _contract.call{value: msg.value}(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );

        emit CallResponse(success, data);
    }
}
