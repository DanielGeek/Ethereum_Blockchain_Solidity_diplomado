// Calling Other Contract

// Contract can call other contracts in 2 ways.

// The easiest way to is to just call it, like A.foo(x, y, z).

// Another way to call other contracts is to use the low-level call.

// This method is not recommended.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Callee {
    uint256 public x;
    uint256 public value;

    function setX(uint256 _x) public returns (uint256) {
        x = _x;
        return x;
    }

    function setXandSendEther(uint256 _x)
        public
        payable
        returns (uint256, uint256)
    {
        x = _x;
        value = msg.value;

        return (x, value);
    }
}

contract Caller {
    function setX(Callee _callee, uint256 _x) public {
        uint256 x = _callee.setX(_x);
    }

    // No recomendada
    function setXWithCall(address _addr, uint256 _x) public {
        // Crear los datos para la llamada
        bytes memory data = abi.encodeWithSignature("setX(uint256)", _x);

        // Llamada de bajo nivel
        (bool success, ) = _addr.call(data);

        // Manejar errores manualmente
        require(success, "Call failed");
    }

    function setXFromAddress(address _addr, uint256 _x) public {
        Callee callee = Callee(_addr);
        callee.setX(_x);
    }

    function setXandSendEther(Callee _callee, uint256 _x) public payable {
        (uint256 x, uint256 value) =
            _callee.setXandSendEther{value: msg.value}(_x);
    }
}
