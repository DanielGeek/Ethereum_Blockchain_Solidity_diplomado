// ABI Decode

// abi.encode encodes data into bytes.

// abi.decode decodes bytes back into data.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AbiDecode {
    struct MyStruct {
        string name;
        uint256[2] nums;
    }

    // example data to send
    // 42, 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, [1,2,3], ["Hello", [100,200]]
    function encode(
        uint256 x,
        address addr,
        uint256[] calldata arr,
        MyStruct calldata myStruct
    ) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, myStruct);
    }

    function decode(bytes calldata data)
        external
        pure
        returns (
            uint256 x,
            address addr,
            uint256[] memory arr,
            MyStruct memory myStruct
        )
    {
        // (uint x, address addr, uint[] memory arr, MyStruct myStruct) = ...
        (x, addr, arr, myStruct) =
            abi.decode(data, (uint256, address, uint256[], MyStruct));
    }
}
