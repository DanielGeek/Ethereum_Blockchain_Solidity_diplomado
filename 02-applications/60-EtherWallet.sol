// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EtherWallet {
    // Almacena la dirección del propietario del contrato, que puede recibir pagos.
    address payable public owner;

    // 🔹 Constructor: Se ejecuta una sola vez al desplegar el contrato.
    constructor() {
        // Define al creador del contrato como el propietario.
        owner = payable(msg.sender);
    }

    // 🔹 Función `receive`: Permite que el contrato reciba ETH directamente.
    receive() external payable {}

    // 🔹 Función `withdraw`: Permite al propietario retirar fondos del contrato.
    function withdraw(uint256 _amount) external {
        // Verifica que solo el propietario pueda retirar fondos.
        require(msg.sender == owner, "caller is not owner");

        // Envía la cantidad solicitada al propietario.
        payable(msg.sender).transfer(_amount);
    }

    // 🔹 Función `getBalance`: Retorna el saldo de ETH almacenado en el contrato.
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
