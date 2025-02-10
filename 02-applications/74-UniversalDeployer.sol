// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 🔹 Este contrato permite desplegar cualquier contrato arbitrario pasando su bytecode
// 🔹 También permite ejecutar funciones en contratos desplegados usando `call`

contract UniversalDeployer {
    event ContractDeployed(address indexed contractAddress);

    // 🔹 Función especial para recibir Ether en el contrato
    receive() external payable {}

    // 📌 Despliega un contrato arbitrario pasando su bytecode
    function deployContract(bytes memory _bytecode)
        external
        payable
        returns (address deployedAddress)
    {
        assembly {
            // 🔹 create(v, p, n): Crea un nuevo contrato
            // v = cantidad de ETH a enviar (callvalue())
            // p = posición de memoria donde empieza el código
            // n = tamaño del código
            deployedAddress := create(callvalue(), add(_bytecode, 0x20), mload(_bytecode))
        }
        
        // 🔥 Si la dirección devuelta es cero, significa que la creación falló
        require(deployedAddress != address(0), "Deployment failed");

        // 🔹 Emitimos un evento con la dirección del contrato desplegado
        emit ContractDeployed(deployedAddress);
    }

    // 📌 Ejecuta una función en un contrato ya desplegado
    function executeTransaction(address target, bytes memory data) external payable {
        // 🔹 Llamamos a la función del contrato objetivo con los datos proporcionados
        (bool success,) = target.call{value: msg.value}(data);
        require(success, "Execution failed");
    }
}

// 🔹 Un contrato de prueba con una función para cambiar el propietario
contract SampleContract1 {
    address public owner = msg.sender;

    function updateOwner(address newOwner) public {
        require(msg.sender == owner, "Unauthorized");
        owner = newOwner;
    }
}

// 🔹 Otro contrato de prueba con un constructor que recibe valores y almacena ETH
contract SampleContract2 {
    address public owner = msg.sender;
    uint256 public balance = msg.value;
    uint256 public param1;
    uint256 public param2;

    constructor(uint256 _param1, uint256 _param2) payable {
        param1 = _param1;
        param2 = _param2;
    }
}

// 🔹 Este contrato proporciona funciones auxiliares para obtener el bytecode de los contratos a desplegar
contract DeploymentHelper {
    
    // 📌 Obtiene el bytecode del primer contrato sin argumentos
    function generateBytecode1() external pure returns (bytes memory) {
        return type(SampleContract1).creationCode;
    }

    // 📌 Obtiene el bytecode del segundo contrato incluyendo parámetros
    function generateBytecode2(uint256 _param1, uint256 _param2)
        external
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(type(SampleContract2).creationCode, abi.encode(_param1, _param2));
    }

    // 📌 Genera los datos de la función para actualizar el propietario en SampleContract1
    function encodeFunctionCall(address newOwner) external pure returns (bytes memory) {
        return abi.encodeWithSignature("updateOwner(address)", newOwner);
    }
}

// 📌 ¿Cómo Usarlo en Remix?
// 	1.	Desplegar UniversalDeployer
// 	•	Selecciona UniversalDeployer y haz Deploy.
// 	2.	Obtener el Bytecode de un Contrato
// 	•	Despliega DeploymentHelper.
// 	•	Llama a generateBytecode1() o generateBytecode2(param1, param2) para obtener el bytecode.
// 	3.	Desplegar un Contrato Arbitrario
// 	•	Copia el bytecode obtenido en el paso anterior.
// 	•	Llama a deployContract(bytecode).
// 	•	Se emitirá un evento con la dirección del contrato desplegado.
// 	4.	Ejecutar una Función en un Contrato Desplegado
// 	•	Usa DeploymentHelper para generar los datos de la función (encodeFunctionCall(nueva_address)).
// 	•	Llama a executeTransaction(contrato_desplegado, datos_codificados).
