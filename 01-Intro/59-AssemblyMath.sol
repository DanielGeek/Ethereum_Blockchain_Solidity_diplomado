// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AssemblyMath {
    
    // 🔹 Función que suma dos números y revierte si hay desbordamiento.
    function yul_add(uint256 x, uint256 y) public pure returns (uint256 z) {
        assembly {
            z := add(x, y) // Suma x + y y almacena el resultado en z.
            
            // Si z < x, significa que ocurrió un overflow (desbordamiento).
            if lt(z, x) { 
                revert(0, 0) // Revierte la transacción.
            }
        }
    }

    // 🔹 Función que multiplica dos números y revierte si hay overflow.
    function yul_mul(uint256 x, uint256 y) public pure returns (uint256 z) {
        assembly {
            // Si x es 0, el resultado es 0 directamente.
            switch x
            case 0 { 
                z := 0 
            }
            default {
                z := mul(x, y) // Multiplicación de x * y.

                // Verifica si ocurrió un overflow en la multiplicación.
                // Si z / x no es igual a y, significa que hubo desbordamiento.
                if iszero(eq(div(z, x), y)) { 
                    revert(0, 0) // Revierte la transacción.
                }
            }
        }
    }

    // 🔹 Función para redondear un número al múltiplo más cercano de b.
    function yul_fixed_point_round(uint256 x, uint256 b)
        public
        pure
        returns (uint256 z)
    {
        assembly {
            // Calculamos la mitad del valor de b para determinar si debemos redondear hacia arriba.
            let half := div(b, 2)

            // Sumamos la mitad de b a x para redondearlo al múltiplo más cercano.
            z := add(x, half)

            // Redondeamos dividiendo por b y multiplicando nuevamente por b.
            z := mul(div(z, b), b)

            // 🔹 Ejemplo con b = 100:
            //   - Si x = 90 → 90 + 50 = 140 → (140 / 100) * 100 = 100 (redondeado a 100).
            //   - Si x = 160 → 160 + 50 = 210 → (210 / 100) * 100 = 200 (redondeado a 200).
        }
    }
}
