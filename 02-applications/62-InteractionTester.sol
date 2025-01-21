// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Interfaz para interactuar con SecureMultiWallet
interface ISecureMultiWallet {
    function proposeTransaction(address _recipient, uint256 _amount, bytes memory _payload) external;
}

contract InteractionTester {
    uint256 public counter;

    function increment(uint256 amount) public {
        counter += amount;
    }

    function generatePayload() public pure returns (bytes memory) {
        return abi.encodeWithSignature("increment(uint256)", 123);
    }

    function sendToSecureMultiWallet(address multiSigWallet, address target) public {
        bytes memory data = generatePayload();
        ISecureMultiWallet(multiSigWallet).proposeTransaction(target, 0, data);
    }
}