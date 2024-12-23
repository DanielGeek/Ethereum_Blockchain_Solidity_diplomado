// For and While Loop
// Solidity supports for, while, and do while loops.

// Don't write loops that are unbounded as this can hit the gas limit, causing your transaction to fail.

// For the reason above, while and do while loops are rarely used.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Loop {
    // uint256 public i;
    // uint256 public j;

    function loop() public pure {
        // for loop
        for (uint256 i = 0; i < 10; i++) {
            if (i == 3) {
                // Skip to next iteration with continue
                continue;
            }
            if (i == 5) {
                // Exit loop with break
                break;
            }
        }

        // while loop
        uint256 j;
        while (j < 10) {
            j++;
        }
    }
}
