// Try Catch
// try / catch can only catch errors from external function calls and contract creation.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// External contract used for try / catch examples
contract Foo {
    address public owner;

    constructor(address _owner) {
        require(_owner != address(0), "invalid address");
        // 0x01 es el código de error específico que indica que un assert falló.
        // •	El evento registrado contiene el error codificado en bytes:
        // 0x4e487b710000000000000000000000000000000000000000000000000000000000000001
    //     Decodificación:
	// •	0x4e487b71: Selector del error Panic.
	// •	0x01: Código de error específico para un fallo de assert.
        assert(_owner != 0x0000000000000000000000000000000000000001);
        owner = _owner;
    }

    function myFunc(uint256 x) public pure returns (string memory) {
        require(x != 0, "require failed");
        return "my func was called";
    }
}

contract Bar {
    event Log(string message);
    event LogBytes(bytes data);

    Foo public foo;

    constructor() {
        // This Foo contract is used for example of try catch with external call
        foo = new Foo(msg.sender);
    }

    // Example of try / catch with external call
    // tryCatchExternalCall(0) => Log("external call failed")
    // tryCatchExternalCall(1) => Log("my func was called")
    function tryCatchExternalCall(uint256 _i) public {
        try foo.myFunc(_i) returns (string memory result) {
            emit Log(result);
        } catch {
            emit Log("external call failed");
        }
    }

    // Example of try / catch with contract creation
    // tryCatchNewContract(0x0000000000000000000000000000000000000000) => Log("invalid address")
    // tryCatchNewContract(0x0000000000000000000000000000000000000001) => LogBytes("")
    // tryCatchNewContract(0x0000000000000000000000000000000000000002) => Log("Foo created")
    function tryCatchNewContract(address _owner) public {
        try new Foo(_owner) returns (Foo foo) {
            // you can use variable foo here
            emit Log("Foo created");
        } catch Error(string memory reason) {
            // catch failing revert() and require()
            emit Log(reason);
        } catch (bytes memory reason) {
            // catch failing assert()
            emit LogBytes(reason);
        }
    }

    function getPanicMessage(uint256 code) public pure returns (string memory) {
        string[7] memory messages = [
            "Assertion failed (Panic(0x01))",
            "Arithmetic overflow or underflow (Panic(0x11))",
            "Division or modulo by zero (Panic(0x12))",
            "Invalid `enum` value (Panic(0x21))",
            "Storage byte array incorrectly encoded (Panic(0x31))",
            "Out-of-bounds array access (Panic(0x41))",
            "Memory allocation failed (Panic(0x51))"
        ];

        uint256[7] memory codes = [uint256(0x01), uint256(0x11), uint256(0x12), uint256(0x21), uint256(0x31), uint256(0x41), uint256(0x51)];

        for (uint256 i = 0; i < codes.length; i++) {
            if (code == codes[i]) {
                return messages[i];
            }
        }

        return string(abi.encodePacked("Unknown Panic code: 0x", uintToHexString(code)));
    }

    function uintToHexString(uint256 value) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        bytes memory buffer = new bytes(64);
        for (uint256 i = 0; i < 64; i++) {
            buffer[63 - i] = hexSymbols[value & 0xf];
            value >>= 4;
        }
        return string(buffer);
    }
}
