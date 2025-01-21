// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AssemblyError {
    
    // Función que revierte la ejecución si "x" es mayor a 10
    function yul_revert(uint256 x) public pure {
        assembly {
            // "revert(p, s)" termina la ejecución del contrato y revierte los cambios de estado.
            // - "p" (posición en memoria) y "s" (tamaño en bytes) definen los datos devueltos en el error.
            // - revert(0, 0) no devuelve datos en el error, solo finaliza la ejecución.
            
            if gt(x, 10) { 
                revert(0, 0) // Si x > 10, la ejecución se revierte sin devolver datos.
            }
        }
    }
}
