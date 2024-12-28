// Events
// Events allow logging to the Ethereum blockchain. Some use cases for events are:

// Listening for events and updating user interface
// A cheap form of storage

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Event {
    // Event declaration
    // Up to 3 parameters can be indexed.
    // Indexed parameters helps you filter the logs by the indexed parameter
    event Log(address indexed sender, string message);
    event AnotherLog();
    // Uso recomendado indexed:
	// •	Usa indexed para parámetros clave que quieras buscar o filtrar fácilmente (como direcciones o identificadores únicos).
	// •	Usa parámetros no indexed para datos que no necesitas filtrar frecuentemente pero quieres almacenar (como mensajes, descripciones, o datos más grandes).

    function test() public {
        emit Log(msg.sender, "Hello World!");
        emit Log(msg.sender, "Hello EVM!");
        emit AnotherLog();
    }
}
