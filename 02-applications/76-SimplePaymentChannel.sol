// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./76-ECDSA.sol";

// 🔹 Evita ataques de reentrada bloqueando el contrato durante la ejecución
contract SecureExecutionGuard {
    bool private isLocked;

    // 🔹 Modificador para prevenir ataques de reentrada (Reentrancy Attack)
    modifier preventReentrancy() {
        require(!isLocked, "Reentrancy attempt detected"); // Verifica que no esté bloqueado
        isLocked = true; // Bloquea la ejecución
        _;
        isLocked = false; // Desbloquea después de la ejecución
    }
}

// 🔹 Canal de pago unidireccional seguro para transferencias fuera de la cadena (off-chain)
contract SecurePaymentChannel is SecureExecutionGuard {
    using ECDSA for bytes32;

    address payable public payer; // Dirección del remitente (Alice)
    address payable public payee; // Dirección del receptor (Bob)
    uint256 private constant VALIDITY_PERIOD = 7 days; // Duración del canal de pago
    uint256 public expirationTime; // Fecha de vencimiento del canal

    // 🔹 Constructor: Se despliega el contrato con el receptor definido y fondos enviados por el remitente
    constructor(address payable _payee) payable {
        require(_payee != address(0), "Invalid receiver address"); // Validación de dirección
        payer = payable(msg.sender); // Asigna al remitente como quien despliega el contrato
        payee = _payee; // Se asigna el receptor
        expirationTime = block.timestamp + VALIDITY_PERIOD; // Establece el tiempo de expiración
    }

    // 🔹 Genera un hash único para una cantidad de pago específica
    function _computeHash(uint256 _amount) private view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _amount)); 
        // 🔹 Se incluye la dirección del contrato para evitar ataques de repetición (Replay Attack)
    }

    // 🔹 Convierte el hash en formato de mensaje firmado por Ethereum (EIP-191)
    function _getSignedHash(uint256 _amount) private view returns (bytes32) {
        return _computeHash(_amount).toEthSignedMessageHash();
    }

    // 🔹 Verifica que la firma proporcionada sea válida y que provenga del remitente
    function _validateSignature(uint256 _amount, bytes memory _signature)
        private
        view
        returns (bool)
    {
        return _getSignedHash(_amount).recover(_signature) == payer; 
        // 🔹 Recupera la dirección del firmante y la compara con la del remitente
    }

    // 🔹 Permite al receptor reclamar su pago enviando un mensaje firmado por el remitente
    function claimPayment(uint256 _amount, bytes memory _signature) external preventReentrancy {
        require(msg.sender == payee, "Unauthorized"); // Verifica que solo el receptor pueda ejecutar esto
        require(_validateSignature(_amount, _signature), "Invalid signature"); // Verifica la firma

        (bool success,) = payee.call{value: _amount}(""); // Envía el pago al receptor
        require(success, "Transaction failed"); // Verifica que la transacción se ejecutó correctamente

        selfdestruct(payer); // 🔥 Destruye el contrato y devuelve los fondos restantes al remitente
    }

    // 🔹 Permite al remitente recuperar los fondos si el contrato ha expirado
    function revokeChannel() external {
        require(msg.sender == payer, "Only sender can cancel"); // Solo el remitente puede cancelar
        require(block.timestamp >= expirationTime, "Payment channel is still active"); // Verifica que el canal haya expirado
        selfdestruct(payer); // 🔥 Destruye el contrato y devuelve los fondos restantes al remitente
    }
}
