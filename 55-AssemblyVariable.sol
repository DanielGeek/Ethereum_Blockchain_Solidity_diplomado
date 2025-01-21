// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AssemblyVariable {
    function yul_let() public pure returns (uint256 z) {
        assembly {
            // Lenguaje utilizado dentro del bloque es Yul
            // Definir una variable local 'x' con el valor 123
            let x := 123 

            // Asignar el valor 456 a 'z', la variable de retorno
            z := 456
        }
    }
}
