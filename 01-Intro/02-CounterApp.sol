// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract CounterApp {
    // Storage Limits for uint256:
	// •	uint256 (Unsigned Integer, 256-bit):
	// •	Can store values from 0 to 2^256 - 1 (approximately 1.1579209 x 10^77).
	// •	This data type is typically used for large integers in Solidity.
    uint256 public count;

    // Function to get the current count
    // 1. view Functions
	// •	Definition: A view function can read the state of the blockchain but cannot modify it.
	// •	Usage: When you only need to retrieve data from the blockchain and do not intend to change it.
    function get() public view returns (uint256) {
        return count;
    }

    // Function to increment count by 1
    function inc() public {
        count += 1;
    }

    // Function to decrement count by 1
    function dec() public {
        // This function will fail if count = 0
        require(count > 0, "Counter cannot by negative");
        count -= 1;
    //     1.	Error Handling:
	// •	The dec function lacks explicit error handling for underflows, but Solidity’s built-in checks for arithmetic operations (>=0.8.x) 
    //     will automatically revert the transaction if the operation would result in an underflow.
    }
}
