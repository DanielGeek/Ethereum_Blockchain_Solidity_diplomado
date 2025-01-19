// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/* 
    Firma de Verificación

    Este contrato permite verificar una firma digital de un mensaje firmado off-chain (fuera de la cadena) 
    utilizando funciones criptográficas en un contrato inteligente.

    La verificación es útil para casos como la autenticación de usuarios, validación de transacciones, 
    y la validación de mensajes sin necesidad de mover la firma real a la cadena.

    Pasos para firmar y verificar:
    # Firma
    1. Crear el mensaje a firmar.
    2. Hashear el mensaje.
    3. Firmar el hash (off-chain, mantén la clave privada secreta).

    # Verificación
    1. Recrear el hash del mensaje original.
    2. Recuperar la dirección del firmante a partir de la firma y el hash.
    3. Comparar la dirección recuperada con la dirección que se dice ser la del firmante.
*/

contract VerifySignature {
    
    // 1. Obtener el hash del mensaje
    // Esta función recibe los componentes del mensaje y devuelve un hash único
    // que será utilizado para firmar. Los datos que se utilizan son:
    // - _to: Dirección de la persona o contrato al que se dirige el mensaje.
    // - _amount: Monto relacionado con la transacción (si aplica).
    // - _message: El contenido del mensaje.
    // - _nonce: Un valor único para prevenir ataques de repetición (replay attacks).
    function getMessageHash(
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce
    ) public pure returns (bytes32) {
        // La función keccak256 genera un hash a partir de la concatenación de los parámetros del mensaje
        // usando el formato adecuado (abi.encodePacked).
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    // 2. Convertir el mensaje firmado en un formato compatible con Ethereum
    // Ethereum requiere un formato específico para las firmas, añadiendo un prefijo
    // "\x19Ethereum Signed Message\n" seguido de la longitud y el hash del mensaje.
    // Esto evita que los datos sean interpretados como una firma de otro tipo de mensaje.
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        // El prefijo garantiza que el hash firmado sea tratado como un mensaje firmado en Ethereum.
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    // 3. Verificación de la firma
    // Esta función recibe el firmante reclamado, los datos del mensaje, y la firma.
    // La firma es un valor generado fuera de la cadena (off-chain) usando la clave privada.
    // Se verifica si el firmante es el correcto, es decir, si la firma corresponde con el mensaje y el firmante esperado.
    function verify(
        address _signer,
        address _to,
        uint256 _amount,
        string memory _message,
        uint256 _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        // Primero recreamos el hash del mensaje usando los parámetros originales.
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        
        // Luego obtenemos el formato de mensaje firmado necesario para Ethereum.
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        // Comprobamos si el firmante recuperado de la firma corresponde con el que se esperaba.
        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    // 4. Recuperar la dirección del firmante
    // Usamos la función ecrecover para obtener la dirección del firmante a partir de la firma y el hash.
    // ecrecover es una función nativa de Ethereum que extrae la dirección de una firma.
    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        // Desglosamos la firma en sus tres componentes: r, s, v.
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        // Usamos ecrecover para recuperar la dirección del firmante a partir del hash del mensaje firmado y la firma.
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    // 5. Dividir la firma en sus componentes
    // La firma está compuesta por tres partes: r, s y v. Esta función descompone la firma en estos componentes.
    // r y s son los valores criptográficos de la firma y v es la versión de la firma (indica si es válida o no).
    function splitSignature(bytes memory sig)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        // Comprobamos que la firma tiene la longitud correcta (65 bytes).
        require(sig.length == 65, "invalid signature length");

        // Usamos ensamblador para extraer r, s y v de la firma (la firma es un array de bytes de 65 bytes).
        assembly {
            r := mload(add(sig, 32))  // Los primeros 32 bytes después del prefijo de longitud contienen 'r'.
            s := mload(add(sig, 64))  // Los siguientes 32 bytes contienen 's'.
            v := byte(0, mload(add(sig, 96)))  // El último byte contiene 'v'.
        }

        // Los valores r, s, v son retornados de forma implícita.
    }
}