// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

struct Point {
    uint256 x;
    uint256 y;
}

error Unauthorized(address caller);

function add(uint256 x, uint256 y) pure returns (uint256) {
    return x + y;
}

contract Imported {
    string public name = "Imported";
}
