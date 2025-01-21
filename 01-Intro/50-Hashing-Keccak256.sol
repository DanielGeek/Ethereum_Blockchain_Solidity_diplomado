// Keccak-256 es una función hash criptográfica unidireccional, lo que significa que no se puede decodificar o
// revertir directamente para obtener el valor original.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract HashFunction {
    /*
    * 📌 Calcula el hash Keccak-256 de los datos de entrada.
    * 
    * 🔹 Utilidad:
    * - Se puede usar para crear identificadores únicos basados en los parámetros ingresados.
    * - Se usa en contratos de votación, loterías y mecanismos de verificación.
    *
    * 📌 Importante:
    * - `keccak256` devuelve un `bytes32`, un hash de 256 bits.
    * - `abi.encodePacked` concatena los valores en una sola secuencia de bytes antes de calcular el hash.
    */
    function hash(string memory _text, uint256 _num, address _addr)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_text, _num, _addr));
    }

    /*
    * 📌 Ejemplo de colisión de hash
    *
    * 🔹 Problema:
    * - `abi.encodePacked` puede generar colisiones cuando se combinan múltiples variables dinámicas.
    * - Dos entradas diferentes pueden producir el mismo hash.
    *
    * 🔹 Ejemplo de colisión:
    * - encodePacked("AAA", "BBB") → `AAABBB`
    * - encodePacked("AA", "ABBB") → `AAABBB`
    *
    * 🔹 Solución:
    * - En lugar de `abi.encodePacked`, usar `abi.encode` para evitar colisiones.
    */
    function collision(string memory _text, string memory _anotherText)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_text, _anotherText));
    }
}

contract GuessTheMagicWord {
    /*
    * 📌 Juego: Adivinar la palabra mágica
    *
    * 🔹 Objetivo:
    * - El contrato almacena un hash de la palabra "Solidity".
    * - Un usuario intenta adivinar la palabra correcta.
    * - Si el hash de la palabra ingresada coincide con el hash almacenado, devuelve `true`.
    *
    * 🔹 Seguridad:
    * - Como solo se almacena el hash, nadie puede leer directamente la respuesta.
    */
    bytes32 public answer =
        0x60298f78cc0b47170ba79c10aa3851d7648bd96f2f8e46a19dbc777c36fb0c00;

    /*
    * 📌 Adivinar la palabra
    *
    * 🔹 ¿Cómo funciona?
    * - Convierte la palabra ingresada en un hash usando `keccak256`.
    * - Compara el hash con el `answer` almacenado.
    * - Devuelve `true` si el usuario ingresó "Solidity", `false` en caso contrario.
    *
    * 🔹 ¿Cómo jugar?
    * - Llamar a `guess("Solidity")` → `true`
    * - Llamar a `guess("Ethereum")` → `false`
    */
    function guess(string memory _word) public view returns (bool) {
        return keccak256(abi.encodePacked(_word)) == answer;
    }
}
