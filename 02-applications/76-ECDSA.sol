// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 📌 Librería ECDSA para verificación de firmas digitales en Ethereum
// 🔹 Proporciona funciones para recuperar la dirección de un firmante a partir de una firma
// 🔹 Permite la validación de firmas de mensajes firmados fuera de la cadena (off-chain)
library ECDSA {
    
    // 🔹 Enumeración de posibles errores al recuperar la firma
    enum RecoverError {
        NoError,                  // No hay error
        InvalidSignature,          // Firma inválida
        InvalidSignatureLength,    // Longitud de firma incorrecta
        InvalidSignatureS,         // Valor 's' inválido en la firma
        InvalidSignatureV          // Valor 'v' inválido en la firma
    }

    // 🔹 Función privada para manejar errores
    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // No hay error, simplemente retorna
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    // 🔹 Intenta recuperar la dirección del firmante a partir del hash y la firma
    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address, RecoverError)
    {
        // Verifica la longitud de la firma:
        // - 65 bytes: r, s, v (formato estándar)
        // - 64 bytes: r, vs (formato comprimido EIP-2098)
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // 📌 Extrae los valores r, s y v de la firma usando ensamblador
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // 📌 Extrae los valores r y vs de la firma comprimida
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    // 🔹 Recupera la dirección del firmante (versión simplificada)
    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error); // Maneja cualquier error detectado
        return recovered;
    }

    // 🔹 Recupera el firmante a partir de hash y firma comprimida (EIP-2098)
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs)
        internal
        pure
        returns (address, RecoverError)
    {
        // 📌 Extrae el valor 's' y el bit más significativo de 'v'
        bytes32 s = vs
            & bytes32(
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            );
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    // 🔹 Recupera la dirección del firmante de la firma comprimida
    function recover(bytes32 hash, bytes32 r, bytes32 vs)
        internal
        pure
        returns (address)
    {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    // 🔹 Intenta recuperar la dirección del firmante a partir de r, s y v
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (address, RecoverError)
    {
        // 📌 Evita la maleabilidad de firmas (EIP-2)
        if (
            uint256(s)
                > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // 📌 Utiliza ecrecover para obtener la dirección del firmante
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    // 🔹 Recupera la dirección del firmante de la firma estándar
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (address)
    {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    // 🔹 Convierte un hash a un mensaje firmado en formato Ethereum (EIP-191)
    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        // 📌 Prepara el mensaje en formato estándar Ethereum
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
    }
}
