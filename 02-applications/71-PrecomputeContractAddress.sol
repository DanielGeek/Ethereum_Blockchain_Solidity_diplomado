// 🚀 PASO 1: Desplegar el contrato Factory
// 	1.	Compila el código en Remix.
// 	2.	Despliega el contrato Factory o AdvancedFactory (si quieres usar el método con ensamblador).
// 	3.	Copia la dirección del contrato Factory o AdvancedFactory después de desplegarlo.

// 🚀 PASO 2: Precomputar la Dirección (Opcional)

// Si deseas conocer la dirección del contrato antes de desplegarlo, usa computeAddress:
// 	1.	Ve a la pestaña “Deploy & Run Transactions” en Remix.
// 	2.	Selecciona AdvancedFactory (si usas el método con ensamblador).
// 	3.	Llama a la función getBytecode(owner, value).
// 	•	owner: Una dirección válida (puede ser la tuya).
// 	•	value: Un número cualquiera (por ejemplo, 42).
// 	•	Copia el resultado del bytecode.
// 	4.	Llama a la función computeAddress(bytecode, salt).
// 	•	bytecode: El resultado obtenido en el paso anterior.
// 	•	salt: Un número único (por ejemplo, 12345).
// 	•	Esta función te mostrará la dirección futura del contrato.
// 🚀 PASO 3: Desplegar el contrato TestContract

// Ahora, usa Factory o AdvancedFactory para desplegar TestContract.

// 📌 Método sin ensamblador (Factory)
// 	1.	Llama a la función deployContract(owner, value, salt).
// 	•	owner: Tu dirección en Remix.
// 	•	value: Un número (ejemplo 42).
// 	•	salt: Un número aleatorio (ejemplo 12345).
// 	2.	Remix mostrará la dirección del nuevo contrato.
// 	3.	Copia la dirección y añádela manualmente en “At Address” para interactuar con él.

// 📌 Método con ensamblador (AdvancedFactory)
// 	1.	Llama a getBytecode(owner, value) y copia el bytecode.
// 	2.	Llama a deployWithCreate2(bytecode, salt).
// 	•	bytecode: El código obtenido antes.
// 	•	salt: Usa el mismo valor que en computeAddress (para que la dirección coincida).
// 	3.	Confirma la transacción y copia la dirección del contrato desplegado.

// 🚀 PASO 4: Interactuar con TestContract
// 	1.	Añade la dirección del contrato desplegado en “At Address” en Remix.
// 	2.	Llama a getBalance() para verificar si tiene ETH.
// 	3.	Consulta owner() y value() para ver los valores iniciales.

//  CONSEJOS
// 	•	Si solo quieres desplegar sin precomputar la dirección, usa Factory.
// 	•	Si quieres predecir la dirección antes de desplegar, usa AdvancedFactory.
// 	•	Puedes enviar ETH en la transacción al desplegar el contrato (value en Remix).

// Convertir el número 123 a bytes32
// 0x000000000000000000000000000000000000000000000000000000000000007b
// Este valor puede usarse directamente en Solidity para precomputar direcciones con CREATE2. 🚀


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
    🔹 Este contrato actúa como una fábrica para desplegar otros contratos.
    🔹 Utiliza CREATE2 para predecir la dirección antes de desplegar el contrato.
*/
contract Factory {
    // Evento que emite la dirección del contrato desplegado
    event ContractDeployed(address contractAddress, bytes32 salt);

    /*
        📌 Función para desplegar un contrato con CREATE2 sin usar ensamblador
        🔹 Recibe la dirección del propietario (_owner), un número (_value) y un salt único.
        🔹 Retorna la dirección donde se ha desplegado el nuevo contrato.
    */
    function deployContract(address _owner, uint256 _value, bytes32 _salt)
        public
        payable
        returns (address)
    {
        // Se despliega el contrato usando CREATE2 con el parámetro "salt"
        return address(new TestContract{salt: _salt}(_owner, _value));
    }
}

/*
    📌 Versión avanzada con ensamblador para mayor control sobre CREATE2
*/
contract AdvancedFactory {
    event ContractDeployed(address contractAddress, uint256 salt);

    /*
        📌 Paso 1: Obtener el bytecode del contrato a desplegar.
        🔹 Se obtiene el código del contrato "TestContract" y se empaqueta con los parámetros del constructor.
    */
    function getBytecode(address _owner, uint256 _value)
        public
        pure
        returns (bytes memory)
    {
        bytes memory bytecode = type(TestContract).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner, _value));
    }

    /*
        📌 Paso 2: Precomputar la dirección del contrato antes de desplegarlo.
        🔹 Se usa la fórmula CREATE2 para calcular la dirección exacta en la que se desplegará.
    */
    function computeAddress(bytes memory bytecode, uint256 _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), _salt, keccak256(bytecode)
            )
        );

        // 🔹 Se extraen los últimos 20 bytes para obtener la dirección resultante
        return address(uint160(uint256(hash)));
    }

    /*
        📌 Paso 3: Desplegar el contrato usando ensamblador para un control total sobre CREATE2
    */
    function deployWithCreate2(bytes memory bytecode, uint256 _salt) public payable {
        address contractAddress;

        assembly {
            contractAddress := create2(
                callvalue(),   // Enviar ETH si es necesario
                add(bytecode, 0x20), // Salta los primeros 32 bytes que contienen la longitud del bytecode
                mload(bytecode), // Carga el tamaño del bytecode en memoria
                _salt // Usa el salt proporcionado
            )

            // 🔹 Verificar que el contrato se haya desplegado correctamente
            if iszero(extcodesize(contractAddress)) { revert(0, 0) }
        }

        emit ContractDeployed(contractAddress, _salt);
    }
}

/*
    📌 Este es el contrato base que será desplegado por la fábrica.
    🔹 Al desplegarlo con CREATE2, su dirección será predecible antes de existir.
*/
contract TestContract {
    address public owner;
    uint256 public value;

    constructor(address _owner, uint256 _value) payable {
        owner = _owner;
        value = _value;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
