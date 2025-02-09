// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 🔹 Este contrato permite desplegar proxies mínimos que delegan llamadas a otro contrato objetivo
// 🔹 Se usa CREATE para desplegar un nuevo contrato con un código predefinido (bytecode de proxy)
// 🔹 Esto ahorra gas al no duplicar la lógica en cada implementación

contract MinimalProxyClone {
    
    // 📌 Función para clonar un contrato objetivo
    function deployProxyClone(address implementation) external returns (address cloneAddress) {
        bytes20 targetBytes = bytes20(implementation); // Convertimos la dirección en 20 bytes

        assembly {
            // 🏗 1. Reservamos espacio en memoria para el código del proxy (55 bytes)
            let clone := mload(0x40)

            // 🔹 Guardamos los primeros 32 bytes del bytecode del proxy en memoria
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )

            // 🔹 Insertamos la dirección del contrato que queremos clonar (implementation)
            mstore(add(clone, 0x14), targetBytes)

            // 🔹 Guardamos los últimos bytes del código de ejecución del proxy
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            // 🏗 2. Creamos el contrato usando CREATE con el código almacenado en memoria
            cloneAddress := create(0, clone, 0x37)

            // 🔥 Si la dirección devuelta es cero, la creación falló
            if iszero(extcodesize(cloneAddress)) {
                revert(0, 0)
            }
        }
    }
}

contract TestContract {
     address public owner;
     uint256 public value;
     bool public initialized; // Para asegurarnos de que solo se inicializa una vez

    // 🚀 En lugar de usar un constructor, creamos una función de inicialización
    function initialize(address _owner, uint256 _value) public {
        require(!initialized, "Already initialized"); // Evita que se llame más de una vez
        owner = _owner;
        value = _value;
        initialized = true; // Marcamos el contrato como inicializado
    }

    function incrementValue() public returns (uint256) {
        value += 1;
        return value;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
