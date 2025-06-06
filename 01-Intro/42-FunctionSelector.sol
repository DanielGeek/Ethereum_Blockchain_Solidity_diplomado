// Function Selector

// When a function is called, the first 4 bytes of calldata specifies which function to call.

// This 4 bytes is called a function selector.

// Take for example, this code below. It uses call to execute transfer on a contract at the address addr.

// addr.call(abi.encodeWithSignature("transfer(address,uint256)", 0xSomeAddress, 123))

// The first 4 bytes returned from abi.encodeWithSignature(....) is the function selector.

// Perhaps you can save a tiny amount of gas if you precompute and inline the function selector in your code?

// Here is how the function selector is computed.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract FunctionSelector {
    /*
    "transfer(address,uint256)"
    0xa9059cbb
    "transferFrom(address,address,uint256)"
    0x23b872dd
    */
    // Puedes usar este valor en una llamada de bajo nivel como esta:
    // addr.call(abi.encodeWithSelector(0xa9059cbb, 0xSomeAddress, 123));
    function getSelector(string calldata _func)
        external
        pure
        returns (bytes4)
    {
        return bytes4(keccak256(bytes(_func)));
    }
}

