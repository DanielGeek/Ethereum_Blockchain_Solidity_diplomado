// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AssemblyLoop {
    
    // Función que usa un bucle "for" en Yul para incrementar "z" de 0 a 9
    function yul_for_loop() public pure returns (uint256 z) {
        assembly {
            // Estructura de un bucle "for" en Yul:
            // for { inicialización } condición { incremento } { cuerpo del bucle }
            for { let i := 0 } lt(i, 10) { i := add(i, 1) } {
                z := add(z, 1) // Incrementa "z" en 1 en cada iteración
            }

            // Equivalente en Solidity:
            // for (uint256 i = 0; i < 10; i++) {
            //     z++;
            // }
        }
    }

    // Función que usa un bucle "while" en Yul para incrementar "z" hasta que "i" sea 5
    function yul_while_loop() public pure returns (uint256 z) {
        assembly {
            let i := 0 // Inicializa i en 0

            // La estructura de un "while" en Yul es similar a un "for" sin inicialización ni incremento
            for {} lt(i, 5) {} { 
                i := add(i, 1) // Incrementa "i" en 1 en cada iteración
                z := add(z, 1) // Incrementa "z" en 1 en cada iteración
            }

            // Equivalente en Solidity:
            // uint256 i = 0;
            // while (i < 5) {
            //     i++;
            //     z++;
            // }
        }
    }
}