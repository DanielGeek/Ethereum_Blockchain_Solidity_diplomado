// Gas
// How much ether do you need to pay for a transaction?
// You pay gas spent * gas price amount of ether, where

// gas is a unit of computation
// gas spent is the total amount of gas used in a transaction
// gas price is how much ether you are willing to pay per gas
// Transactions with higher gas price have higher priority to be included in a block.

// Unspent gas will be refunded.

// Gas Limit
// There are 2 upper bounds to the amount of gas you can spend

// gas limit (max amount of gas you're willing to use for your transaction, set by you)
// block gas limit (max amount of gas allowed in a block, set by the network)

// Asumiendo un Gas Price Común (Ejemplo):
// 	1.	Gas Usado: 3,000,000 unidades.
// 	2.	Gas Price: 20 gwei (1 gwei = 10^-9 ETH).

// Conversión del Gas Price:


// Gas Price (ETH) = 20 x 10^-9 ETH

// Cálculo:
// Costo Total (ETH) = 3,000,000 x 20 x 10^-9

// Costo Total (ETH) = 0.06 ETH

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Gas {
    uint256 public i = 0;

    // Using up all of the gas that you send causes your transaction to fail.
    // State changes are undone.
    // Gas spent are not refunded.
    function forever() public {
        // Here we run a loop until all of the gas are spent
        // and the transaction fails
        while (true) {
            i += 1;
        }
    }
}
