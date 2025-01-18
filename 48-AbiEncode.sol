// ABI Encode

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Interfaz de un token ERC20 con la función `transfer`
interface IERC20 {
    function transfer(address, uint256) external;
}

contract Token {
    // Un contrato simple que implementa la función `transfer` de ERC20
    function transfer(address, uint256) external {}
}

contract AbiEncode {
    // Función para realizar una llamada directa a otro contrato con datos codificados
    function test(address _contract, bytes calldata data) external {
        // Se realiza la llamada utilizando la función `call`, que permite llamar a cualquier función externa
        (bool ok,) = _contract.call(data);
        require(ok, "call failed");  // Si la llamada falla, se revierte
    }

    // Función para codificar una llamada con la firma de la función (nombre y tipos de parámetros)
    function encodeWithSignature(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // abi.encodeWithSignature codifica la llamada con la firma especificada
        // Se especifica la firma de la función "transfer(address,uint256)" y los parámetros (to, amount)
        // Esta codificación es compatible con la llamada de funciones del contrato externo
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    // Función para codificar una llamada utilizando el selector de la función
    function encodeWithSelector(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // abi.encodeWithSelector utiliza el selector de la función para codificar la llamada
        // El selector es un valor hash único para la función basado en su firma
        // `IERC20.transfer.selector` obtiene el selector para la función `transfer(address,uint256)`
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    // Función para codificar una llamada utilizando la firma y parámetros directamente
    function encodeCall(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        // abi.encodeCall automáticamente codifica la llamada a la función `transfer` del contrato `IERC20`
        // Es una forma más segura de codificar la llamada, ya que no hay posibilidad de errores tipográficos
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }
}
