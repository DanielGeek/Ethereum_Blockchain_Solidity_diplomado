// Explicación de Transient Storage:
// 	1.	Storage (Almacenamiento Permanente):
// 	•	Se almacena en la blockchain y persiste después de las transacciones.
// 	•	Es costoso en términos de gas.
// 	2.	Memory (Memoria Temporal):
// 	•	Se utiliza solo durante la ejecución de una función.
// 	•	No persiste después de que la función termina.
// 	3.	Transient Storage (Almacenamiento Transitorio):
// 	•	Es una nueva categoría introducida con actualizaciones como EVM Cancun.
// 	•	Los datos en Transient Storage se borran automáticamente al final de la transacción.
// 	•	Se accede mediante instrucciones específicas como tstore (guardar) y tload (leer).
// 	•	Es útil para datos temporales compartidos entre diferentes llamadas dentro de la misma transacción.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// IMPORTANTE: Asegúrate de que tu VM esté configurada para EVM Cancun o posterior.

// Interfaces para interacción con otros contratos
interface ITest {
    function val() external view returns (uint256); // Devuelve un valor
    function test() external; // Realiza alguna acción
}

// Contrato que compara almacenamiento normal y transitorio
contract Callback {
    uint256 public val; // Variable de almacenamiento normal en blockchain

    // Fallback es llamado automáticamente cuando el contrato recibe datos que no coinciden con ninguna función
    fallback() external {
        // Asigna el valor devuelto por el contrato que interactúa con este
        val = ITest(msg.sender).val();
    }

    // Llama a la función `test` en el contrato objetivo
    function test(address target) external {
        ITest(target).test();
    }
}

// Contrato que utiliza almacenamiento normal (Storage)
contract TestStorage {
    uint256 public val; // Almacenamiento permanente en blockchain

    // Función que asigna un valor y llama al `fallback` de `msg.sender`
    function test() public {
        val = 123; // Se guarda en almacenamiento permanente
        bytes memory b = ""; // Datos vacíos
        msg.sender.call(b); // Llama al contrato que inició la transacción
    }
}

// Contrato que utiliza almacenamiento transitorio
contract TestTransientStorage {
    // Define una posición constante en Transient Storage
    bytes32 constant SLOT = 0;

    // Función que guarda datos en Transient Storage
    function test() public {
        assembly {
            // Guardar el valor 321 en la posición `SLOT`
            tstore(SLOT, 321)
        }
        bytes memory b = ""; // Datos vacíos
        msg.sender.call(b); // Llama al contrato que inició la transacción
    }

    // Función para leer el valor almacenado en Transient Storage
    function val() public view returns (uint256 v) {
        assembly {
            // Leer el valor desde la posición `SLOT`
            v := tload(SLOT)
        }
    }
}

// Contrato para probar ataques de reentrada
contract MaliciousCallback {
    uint256 public count = 0; // Contador de reentradas

    // Fallback que intenta llamar repetidamente a `test` del contrato objetivo
    fallback() external {
        ITest(msg.sender).test(); // Reentrada
    }

    // Inicia un ataque de reentrada
    function attack(address _target) external {
        ITest(_target).test(); // Llama inicialmente al contrato objetivo
    }
}

// Protección básica contra reentrancia usando un bloqueo booleano
contract ReentrancyGuard {
    bool private locked; // Estado de bloqueo

    modifier lock() {
        require(!locked, "Reentrancy detected"); // Verifica que no esté bloqueado
        locked = true; // Bloquea la ejecución
        _;
        locked = false; // Libera el bloqueo
    }

    // Función protegida contra reentrancia (usa gas normal)
    function test() public lock {
        bytes memory b = ""; // Datos vacíos
        msg.sender.call(b); // Llama al contrato que inició la transacción
    }
}

// Protección contra reentrancia usando Transient Storage
contract ReentrancyGuardTransient {
    bytes32 constant SLOT = 0; // Posición en Transient Storage

    // Modificador que utiliza Transient Storage para protección
    modifier lock() {
        assembly {
            if tload(SLOT) { revert(0, 0) } // Si SLOT ya está en uso, revertir
            tstore(SLOT, 1) // Bloquea la posición
        }
        _;
        assembly {
            tstore(SLOT, 0) // Libera la posición al finalizar
        }
    }

    // Función protegida contra reentrancia usando Transient Storage
    function test() external lock {
        bytes memory b = ""; // Datos vacíos
        msg.sender.call(b); // Llama al contrato que inició la transacción
    }
}

// Comparación entre ReentrancyGuard y ReentrancyGuardTransient
// 	1.	ReentrancyGuard:
// 	•	Usa un booleano en storage para bloquear llamadas reentrantes.
// 	•	Consume más gas (~27,587 gas).
// 	•	Más costoso en términos de almacenamiento y lectura.
// 	2.	ReentrancyGuardTransient:
// 	•	Usa Transient Storage para el bloqueo.
// 	•	Es más barato (~4,909 gas).
// 	•	No persiste en la blockchain después de la transacción.