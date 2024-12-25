// User Defined Value Types

/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Este código demuestra cómo usar "User Defined Value Types" (UDVT) en Solidity.
// UDVT se utilizan para agregar más estructura y seguridad a los datos primitivos.
// Basado en código de Optimism: 
// https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/dispute/lib/LibUDT.sol

// Definimos nuevos tipos basados en uint64 y uint128
// Estos nuevos tipos tienen reglas estrictas y no se pueden usar directamente como uint64/uint128.
type Duration is uint64; // Duración específica en el tiempo
type Timestamp is uint64; // Momento específico en el tiempo
type Clock is uint128;    // Combina un Duration y un Timestamp en un solo valor

// Librería para trabajar con el tipo Clock usando UDVT
library LibClock {
    // Combina un Duration y un Timestamp en un único Clock
    function wrap(Duration _duration, Timestamp _timestamp)
        internal
        pure
        returns (Clock clock_)
    {
        assembly {
            // data | Duration | Timestamp
            // bit  | 0 ... 63 | 64 ... 127
            // Guardamos `_duration` en los primeros 64 bits y `_timestamp` en los últimos 64 bits.
            clock_ := or(shl(0x40, _duration), _timestamp)
        }
    }

    // Extrae el Duration de un Clock
    function duration(Clock _clock)
        internal
        pure
        returns (Duration duration_)
    {
        assembly {
            // Desplazamos los bits 64 lugares hacia la derecha para obtener el Duration
            duration_ := shr(0x40, _clock)
        }
    }

    // Extrae el Timestamp de un Clock
    function timestamp(Clock _clock)
        internal
        pure
        returns (Timestamp timestamp_)
    {
        assembly {
            // Eliminamos los bits de Duration y dejamos solo los de Timestamp
            timestamp_ := shr(0xC0, shl(0xC0, _clock))
        }
    }
}

// Librería alternativa sin usar UDVT
library LibClockBasic {
    // Combina uint64 `_duration` y `_timestamp` en un uint128 "Clock"
    function wrap(uint64 _duration, uint64 _timestamp)
        internal
        pure
        returns (uint128 clock)
    {
        assembly {
            clock := or(shl(0x40, _duration), _timestamp)
        }
    }
}

// Ejemplos prácticos
contract Examples {
    // Ejemplo sin usar User Defined Value Types (UDVT)
    function example_no_uvdt() external view {
        uint128 clock; // Definimos un Clock como uint128
        uint64 d = 1;  // Duración en segundos
        uint64 t = uint64(block.timestamp); // Timestamp actual

        // Usamos la librería básica para combinar `d` y `t`
        clock = LibClockBasic.wrap(d, t);

        // Aquí cometemos un error: intercambiamos el orden de `d` y `t`.
        // Este error pasa desapercibido porque ambos son uint64.
        clock = LibClockBasic.wrap(t, d); 
        // ¡Error silencioso! Esto puede causar bugs difíciles de rastrear.
    }

    // Ejemplo con User Defined Value Types (UDVT)
    function example_uvdt() external view {
        // Convertimos valores primitivos a tipos definidos por el usuario
        Duration d = Duration.wrap(1); // Duración de 1 segundo
        Timestamp t = Timestamp.wrap(uint64(block.timestamp)); // Timestamp actual

        // Convertimos los UDVT de vuelta a sus valores primitivos
        uint64 d_u64 = Duration.unwrap(d); // d_u64 = 1
        uint64 t_u64 = Timestamp.unwrap(t); // t_u64 = block.timestamp

        // Usamos la librería LibClock para combinar Duration y Timestamp
        Clock clock = Clock.wrap(0); // Inicializamos un Clock con 0
        clock = LibClock.wrap(d, t); // Correcto: combinamos `d` y `t`.

        // Intentamos intercambiar `d` y `t` en el orden incorrecto
        // Esto generará un error de compilación porque los tipos no coinciden.
        // clock = LibClock.wrap(t, d); // ¡No compila!
        // Este comportamiento ayuda a evitar errores comunes.
    }
}