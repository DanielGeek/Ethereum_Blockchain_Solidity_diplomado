// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AssemblyIf {
    
    // Función que usa una estructura condicional "if" en Yul (ensamblador de Solidity)
    function yul_if(uint256 x) public pure returns (uint256 z) {
        assembly {
            // if (condición) { código a ejecutar }
            // Yul no tiene una cláusula "else", solo se ejecuta el código si la condición es verdadera.
            
            // En este caso, si "x" es menor que 10, se asigna 99 a "z".
            if lt(x, 10) { z := 99 }
            
            // "lt" es la abreviatura de "less than" (menor que) en ensamblador de EVM.
            // Equivalente en Solidity: if (x < 10) { z = 99; }
        }
    }

    // Función que usa "switch" en Yul, similar a un switch-case en Solidity o JavaScript.
    function yul_switch(uint256 x) public pure returns (uint256 z) {
        assembly {
            // La estructura "switch" permite evaluar diferentes casos para una misma variable.
            switch x
            case 1 { z := 10 }  // Si x == 1, asigna 10 a z.
            case 2 { z := 20 }  // Si x == 2, asigna 20 a z.
            default { z := 0 }  // Si x no es 1 ni 2, asigna 0 a z.

            // Equivalente en Solidity:
            // if (x == 1) { z = 10; }
            // else if (x == 2) { z = 20; }
            // else { z = 0; }
        }
    }
}