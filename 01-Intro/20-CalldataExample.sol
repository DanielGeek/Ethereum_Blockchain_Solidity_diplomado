// Ventajas de usar calldata
// 	1.	Eficiencia:
// 	•	calldata es más económico en términos de gas porque no se copia a la memoria como ocurre con los datos en memory.
// 	2.	Seguridad:
// 	•	Los datos en calldata no pueden ser modificados accidentalmente, lo que reduce el riesgo de errores.
// 	3.	Ideal para funciones de solo lectura:
// 	•	Cuando una función solo necesita procesar datos de entrada y no modificarlos, calldata es la mejor opción.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract CalldataExample {
    // Función que suma los elementos de un array en `calldata`
    function sumArray(uint256[] calldata arr) external pure returns (uint256) {
        uint256 sum = 0;

        // Iteramos sobre el array usando `calldata` (más eficiente)
        for (uint256 i = 0; i < arr.length; i++) {
            sum += arr[i];
        }

        return sum; // Retorna la suma de los elementos
    }
}
