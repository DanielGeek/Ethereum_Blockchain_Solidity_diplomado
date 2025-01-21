// 🚀 Utilidad de las operaciones bitwise en Solidity:
// 
// 1️⃣ **Optimización de Gas**: Las operaciones bitwise son más eficientes en términos de gas que las operaciones aritméticas tradicionales.
// 2️⃣ **Manejo de Permisos y Flags**: Se pueden usar para almacenar múltiples valores booleanos en un solo `uint256`, reduciendo el consumo de almacenamiento en la blockchain.
// 3️⃣ **Compresión de Datos**: Permiten empaquetar información en menos espacio, útil en aplicaciones como NFTs, gaming y sistemas de votación on-chain.
// 4️⃣ **Cálculos Matemáticos Rápidos**: Multiplicar o dividir por potencias de 2 es más rápido usando desplazamientos (`<<` y `>>`) en lugar de multiplicación o división.
// 5️⃣ **Manipulación de Bits en Criptografía**: Se usan en algoritmos de hashing, generación de direcciones y pruebas de Merkle Trees.
// 6️⃣ **Filtrado y Extracción de Información**: Se pueden usar máscaras (`&`) para obtener partes específicas de un número sin necesidad de cálculos adicionales.
//
// 📌 En contratos inteligentes, cada unidad de gas ahorrada puede marcar la diferencia, por lo que entender y aplicar estas técnicas es clave para desarrollar sistemas eficientes. 🚀🔥

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Contrato que demuestra el uso de operadores bitwise en Solidity.
contract BitwiseOps {
    
    // Operador AND (&): Realiza una comparación bit a bit y devuelve 1 si ambos bits son 1.
    // x     = 1110 (14)
    // y     = 1011 (11)
    // x & y = 1010 (10)
    function and(uint256 x, uint256 y) external pure returns (uint256) {
        return x & y;
    }

    // Operador OR (|): Realiza una comparación bit a bit y devuelve 1 si al menos un bit es 1.
    // x     = 1100 (12)
    // y     = 1001 (9)
    // x | y = 1101 (13)
    function or(uint256 x, uint256 y) external pure returns (uint256) {
        return x | y;
    }

    // Operador XOR (^): Devuelve 1 si los bits son diferentes, 0 si son iguales.
    // x     = 1100 (12)
    // y     = 0101 (5)
    // x ^ y = 1001 (9)
    function xor(uint256 x, uint256 y) external pure returns (uint256) {
        return x ^ y;
    }

    // Operador NOT (~): Invierte los bits (complemento de un número).
    // x  = 00001100 (12)
    // ~x = 11110011 (243, en uint8, porque Solidity usa complemento a dos)
    function not(uint8 x) external pure returns (uint8) {
        return ~x;
    }

    // Operador de desplazamiento a la izquierda (<<): Mueve los bits 'bits' posiciones a la izquierda.
    // 1 << 0 = 0001  --> 0001  (1)
    // 1 << 1 = 0001  --> 0010  (2)
    // 1 << 2 = 0001  --> 0100  (4)
    // 1 << 3 = 0001  --> 1000  (8)
    // 3 << 2 = 0011  --> 1100  (12)
    function shiftLeft(uint256 x, uint256 bits) external pure returns (uint256) {
        return x << bits;
    }

    // Operador de desplazamiento a la derecha (>>): Mueve los bits 'bits' posiciones a la derecha.
    // 8  >> 0 = 1000  --> 1000  (8)
    // 8  >> 1 = 1000  --> 0100  (4)
    // 8  >> 2 = 1000  --> 0010  (2)
    // 8  >> 3 = 1000  --> 0001  (1)
    // 8  >> 4 = 1000  --> 0000  (0)
    function shiftRight(uint256 x, uint256 bits) external pure returns (uint256) {
        return x >> bits;
    }

    // Extraer los últimos n bits de un número usando una máscara bitwise (&).
    // x        = 1101 (13)
    // n        = 3
    // mask     = 0111 (7)
    // x & mask = 0101 (5)
    function getLastNBits(uint256 x, uint256 n) external pure returns (uint256) {
        uint256 mask = (1 << n) - 1; // Crea una máscara con los últimos n bits en 1
        return x & mask;
    }

    // Extraer los últimos n bits usando el operador módulo (%).
    // Es equivalente a aplicar la máscara anterior.
    // 1 << n equivale a 2^n.
    function getLastNBitsUsingMod(uint256 x, uint256 n) external pure returns (uint256) {
        return x % (1 << n);
    }

    // Obtener la posición del bit más significativo (el bit más a la izquierda que sea 1).
    // x = 1100 (12) → el bit más significativo es 1000, que está en la posición 3.
    function mostSignificantBit(uint256 x) external pure returns (uint256) {
        uint256 i = 0;
        while ((x >>= 1) > 0) { // Desplaza x a la derecha hasta que se vuelva 0
            ++i;
        }
        return i;
    }

    // Extraer los primeros n bits de un número x.
    // len es la longitud total de bits en x, que es igual a la posición del bit más significativo + 1.
    // x        = 1110 (14), n = 2, len = 4
    // mask     = 1100 (12)
    // x & mask = 1100 (12)
    function getFirstNBits(uint256 x, uint256 n, uint256 len) external pure returns (uint256) {
        uint256 mask = ((1 << n) - 1) << (len - n); // Crea una máscara con los n bits más significativos
        return x & mask;
    }
}

contract MostSignificantBitFunction {
    // Find most significant bit using binary search
    function mostSignificantBit(uint256 x)
        external
        pure
        returns (uint256 msb)
    {
        // x >= 2 ** 128
        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            msb += 128;
        }
        // x >= 2 ** 64
        if (x >= 0x10000000000000000) {
            x >>= 64;
            msb += 64;
        }
        // x >= 2 ** 32
        if (x >= 0x100000000) {
            x >>= 32;
            msb += 32;
        }
        // x >= 2 ** 16
        if (x >= 0x10000) {
            x >>= 16;
            msb += 16;
        }
        // x >= 2 ** 8
        if (x >= 0x100) {
            x >>= 8;
            msb += 8;
        }
        // x >= 2 ** 4
        if (x >= 0x10) {
            x >>= 4;
            msb += 4;
        }
        // x >= 2 ** 2
        if (x >= 0x4) {
            x >>= 2;
            msb += 2;
        }
        // x >= 2 ** 1
        if (x >= 0x2) msb += 1;
    }
}

contract MostSignificantBitAssembly {
    function mostSignificantBit(uint256 x)
        external
        pure
        returns (uint256 msb)
    {
        assembly {
            let f := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            x := shr(f, x)
            // or can be replaced with add
            msb := or(msb, f)
        }
        assembly {
            let f := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
            x := shr(f, x)
            msb := or(msb, f)
        }
        assembly {
            let f := shl(5, gt(x, 0xFFFFFFFF))
            x := shr(f, x)
            msb := or(msb, f)
        }
        assembly {
            let f := shl(4, gt(x, 0xFFFF))
            x := shr(f, x)
            msb := or(msb, f)
        }
        assembly {
            let f := shl(3, gt(x, 0xFF))
            x := shr(f, x)
            msb := or(msb, f)
        }
        assembly {
            let f := shl(2, gt(x, 0xF))
            x := shr(f, x)
            msb := or(msb, f)
        }
        assembly {
            let f := shl(1, gt(x, 0x3))
            x := shr(f, x)
            msb := or(msb, f)
        }
        assembly {
            let f := gt(x, 0x1)
            msb := or(msb, f)
        }
    }
}
