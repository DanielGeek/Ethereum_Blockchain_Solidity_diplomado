// Conclusión
// 	•	Usa memory cuando necesites trabajar con datos temporales que serán modificados dentro de la función.
// 	•	Usa calldata para datos de entrada que no necesitas modificar, especialmente en funciones públicas o externas.
// 	•	Entender estas ubicaciones ayuda a optimizar costos de gas y mejorar la eficiencia de los contratos inteligentes.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract CompareMemoryAndCalldata {
    // Usando `memory` (copia el array completo)
    function useMemory(uint256[] memory arr) public pure returns (uint256) {
        arr[0] = 42; // Modificable
        return arr[0];
    }

    // Usando `calldata` (más eficiente y no modificable)
    function useCalldata(uint256[] calldata arr) public pure returns (uint256) {
        // arr[0] = 42; // Esto daría error porque `calldata` es de solo lectura
        return arr[0];
    }
}
