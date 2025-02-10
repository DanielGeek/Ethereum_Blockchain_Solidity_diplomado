// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 🔹 Este es un patrón de proxy transparente para contratos actualizables
// 🔹 Separa la lógica del contrato de los datos almacenados en el proxy
// 🔹 Usa `delegatecall` para reenviar llamadas al contrato de implementación

// 📌 Primera versión del contrato lógico
contract CounterLogicV1 {
    uint256 public counter;

    function increase() external {
        counter += 1;
    }
}

// 📌 Segunda versión con función adicional
contract CounterLogicV2 {
    uint256 public counter;

    function increase() external {
        counter += 1;
    }

    function decrease() external {
        counter -= 1;
    }
}

// 📌 Proxy básico con administración manual
contract BasicProxy {
    address public implementation;
    address public admin;

    constructor() {
        admin = msg.sender; // Define al administrador del contrato
    }

        // 📌 Función interna que redirige las llamadas al contrato de implementación usando `delegatecall`
    function _delegate() private {
        // 🔹 delegatecall ejecuta la función en el contexto del proxy, pero usa la lógica del contrato de implementación
        (bool success,) = implementation.delegatecall(msg.data);
        
        // 🔹 Si la llamada falla, revertimos la transacción con un mensaje de error
        require(success, "delegatecall failed");
    }

    // 📌 Fallback function: cualquier llamada que no coincida con una función existente será redirigida a la implementación
    fallback() external payable {
        _delegate(); // 🔹 Redirige la ejecución a la implementación
    }

    // 📌 Recibe Ether en el contrato y lo redirige a la implementación
    receive() external payable {
        _delegate(); // 🔹 Permite recibir pagos en el proxy y reenviarlos a la implementación
    }

    // 📌 Función para actualizar la implementación (solo admin)
    function upgradeTo(address newImplementation) external {
        require(msg.sender == admin, "not authorized");
        implementation = newImplementation;
    }
}

// 📌 Contrato que devuelve los identificadores de funciones
contract DeveloperHelper {
    function getSelectors() external view returns (bytes4, bytes4, bytes4) {
        return (
            SmartProxy.admin.selector,
            SmartProxy.implementation.selector,
            SmartProxy.upgradeTo.selector
        );
    }
}

// 📌 Proxy avanzado con almacenamiento estructurado
contract SmartProxy {
    // 🔹 Definimos ubicaciones de almacenamiento siguiendo EIP-1967 para evitar colisiones
    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant ADMIN_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    constructor() {
        _setAdmin(msg.sender);
    }

    modifier onlyAdmin() {
        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function _getAdmin() private view returns (address) {
        return StorageUtils.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "admin cannot be zero address");
        StorageUtils.getAddressSlot(ADMIN_SLOT).value = newAdmin;
    }

    function _getImplementation() private view returns (address) {
        return StorageUtils.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(newImplementation.code.length > 0, "invalid implementation");
        StorageUtils.getAddressSlot(IMPLEMENTATION_SLOT).value = newImplementation;
    }

    // 📌 Funciones administrativas
    function changeAdmin(address newAdmin) external onlyAdmin {
        _setAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external onlyAdmin {
        _setImplementation(newImplementation);
    }

    function admin() external onlyAdmin returns (address) {
        return _getAdmin();
    }

    function implementation() external onlyAdmin returns (address) {
        return _getImplementation();
    }

    // 📌 Delegación de llamadas a la implementación
    function _delegate(address newImplementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success :=
                delegatecall(gas(), newImplementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch success
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _fallback() private {
        _delegate(_getImplementation());
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }
}

// 📌 Administrador externo del proxy
contract ProxyController {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function getProxyAdmin(address proxy) external view returns (address) {
        (bool success, bytes memory response) =
            proxy.staticcall(abi.encodeCall(SmartProxy.admin, ()));
        require(success, "call failed");
        return abi.decode(response, (address));
    }

    function getProxyImplementation(address proxy)
        external
        view
        returns (address)
    {
        (bool success, bytes memory response) =
            proxy.staticcall(abi.encodeCall(SmartProxy.implementation, ()));
        require(success, "call failed");
        return abi.decode(response, (address));
    }

    function changeProxyAdmin(address payable proxy, address newAdmin)
        external
        onlyOwner
    {
        SmartProxy(proxy).changeAdmin(newAdmin);
    }

    function upgrade(address payable proxy, address newImplementation)
        external
        onlyOwner
    {
        SmartProxy(proxy).upgradeTo(newImplementation);
    }
}

// 📌 Librería para manejar almacenamiento en espacios específicos
library StorageUtils {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 slot)
        internal
        pure
        returns (AddressSlot storage result)
    {
        assembly {
            result.slot := slot
        }
    }
}

// 📌 Contrato de prueba para almacenamiento de valores en un slot
contract TestStorage {
    bytes32 public constant testSlot = keccak256("TEST_SLOT");

    function getStoredValue() external view returns (address) {
        return StorageUtils.getAddressSlot(testSlot).value;
    }

    function writeStoredValue(address newValue) external {
        StorageUtils.getAddressSlot(testSlot).value = newValue;
    }
}

// 📌 Explicación del Código

// 🔹 CounterLogicV1 y CounterLogicV2: Son contratos de lógica que representan la implementación inicial y su actualización.
// 🔹 BasicProxy: Es un proxy básico que permite redirigir llamadas a una implementación sin manejo de administración avanzada.
// 🔹 SmartProxy: Un proxy avanzado que sigue EIP-1967, con almacenamiento estructurado y seguridad mejorada.
// 🔹 ProxyController: Administra actualizaciones y cambios de administrador para SmartProxy.
// 🔹 StorageUtils: Maneja espacios de almacenamiento de manera eficiente en la blockchain.
// 🔹 TestStorage: Permite probar cómo se almacenan valores en slots específicos.

// 🚀 ¿Cómo usarlo en Remix?
// 	1.	Deploy CounterLogicV1 – Guarda la dirección del contrato.
// 	2.	Deploy SmartProxy – Usa changeAdmin() para definir un administrador.
// 	3.	Usa upgradeTo() en SmartProxy y pásale la dirección de CounterLogicV1.
// 	4.	Interactúa con SmartProxy como si fuera CounterLogicV1.
// 	5.	Deploy CounterLogicV2 y usa upgradeTo() para actualizar.
// 	6.	Ahora SmartProxy usa CounterLogicV2, sin cambiar su dirección.

// 📌 ¿Por qué es útil este patrón de proxy transparente?

// ✅ Permite actualizar contratos sin cambiar la dirección.
// ✅ Eficiencia en gas al delegar llamadas sin duplicar almacenamiento.
// ✅ Seguridad al restringir quién puede actualizar (onlyAdmin).
// ✅ Compatible con herramientas como Hardhat y Foundry.