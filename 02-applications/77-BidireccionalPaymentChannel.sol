// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ECDSA.sol";

/*
📌 Canal de pago bidireccional que permite transferencias de Ether en ambas direcciones.

🔹 Flujo del contrato:
1️⃣ Ambos usuarios depositan fondos en una billetera multi-firma.
2️⃣ Se precomputa la dirección del canal de pago.
3️⃣ Intercambian firmas con los saldos iniciales.
4️⃣ Se despliega el canal de pago desde la billetera multi-firma.

🔹 Actualización de balances:
1️⃣ Los usuarios firman los nuevos balances fuera de la cadena.
2️⃣ Cancelan la transacción que hubiera desplegado el canal anterior.
3️⃣ Envían una nueva transacción firmada con el canal actualizado.

🔹 Cierre del canal (con acuerdo):
1️⃣ Se ejecuta una transacción desde la billetera multi-firma para repartir fondos.
2️⃣ Se elimina la transacción que crearía el canal.

🔹 Cierre del canal (sin acuerdo):
1️⃣ Un usuario despliega el canal de pago desde la billetera multi-firma.
2️⃣ Se inicia el proceso de disputa llamando a `startDispute()`.
3️⃣ Los fondos se pueden retirar una vez que el período de disputa expire.
*/

contract BiDirectionalPaymentChannel {
    using ECDSA for bytes32;

    event DisputeStarted(address indexed user, uint256 nonce);
    event FundsWithdrawn(address indexed to, uint256 amount);

    address payable[2] public participants;
    mapping(address => bool) public isParticipant;
    mapping(address => uint256) public accountBalances;

    uint256 public disputeDuration;
    uint256 public expirationTime;
    uint256 public currentNonce;

    // 📌 Modificador para validar que los balances sean correctos
    modifier validateBalances(uint256[2] memory _balances) {
        require(
            address(this).balance >= _balances[0] + _balances[1],
            "Saldo insuficiente en el contrato"
        );
        _;
    }

    // 📌 Inicializa el canal de pago con los usuarios y sus fondos
    constructor(
        address payable[2] memory _participants,
        uint256[2] memory _balances,
        uint256 _expirationTime,
        uint256 _disputeDuration
    ) payable validateBalances(_balances) {
        require(_expirationTime > block.timestamp, "Tiempo de expiracion invalido");
        require(_disputeDuration > 0, "Duracion de disputa inválida");

        for (uint256 i = 0; i < _participants.length; i++) {
            address payable user = _participants[i];
            require(!isParticipant[user], "Usuario duplicado");

            participants[i] = user;
            isParticipant[user] = true;
            accountBalances[user] = _balances[i];
        }

        expirationTime = _expirationTime;
        disputeDuration = _disputeDuration;
    }

    // 📌 Verifica las firmas proporcionadas para asegurar la validez de los datos
    function verifySignatures(
        bytes[2] memory _signatures,
        address _contractAddress,
        address[2] memory _signers,
        uint256[2] memory _balances,
        uint256 _nonce
    ) public pure returns (bool) {
        for (uint256 i = 0; i < _signatures.length; i++) {
            bool isValid = _signers[i] ==
                keccak256(abi.encodePacked(_contractAddress, _balances, _nonce))
                    .toEthSignedMessageHash().recover(_signatures[i]);

            if (!isValid) {
                return false;
            }
        }
        return true;
    }

    // 📌 Modificador para asegurar que las firmas sean correctas antes de actualizar los balances
    modifier checkValidSignatures(
        bytes[2] memory _signatures,
        uint256[2] memory _balances,
        uint256 _nonce
    ) {
        address[2] memory signers;
        for (uint256 i = 0; i < participants.length; i++) {
            signers[i] = participants[i];
        }

        require(
            verifySignatures(_signatures, address(this), signers, _balances, _nonce),
            "Firmas inválidas"
        );

        _;
    }

    // 📌 Modificador para asegurar que solo los participantes puedan ejecutar ciertas funciones
    modifier onlyParticipant() {
        require(isParticipant[msg.sender], "Acceso no autorizado");
        _;
    }

    // 📌 Inicia una disputa y actualiza los balances en caso de desacuerdo
    function startDispute(
        uint256[2] memory _balances,
        uint256 _nonce,
        bytes[2] memory _signatures
    )
        public
        onlyParticipant
        checkValidSignatures(_signatures, _balances, _nonce)
        validateBalances(_balances)
    {
        require(block.timestamp < expirationTime, "El período de disputa ha expirado");
        require(_nonce > currentNonce, "Nonce debe ser mayor al anterior");

        for (uint256 i = 0; i < _balances.length; i++) {
            accountBalances[participants[i]] = _balances[i];
        }

        currentNonce = _nonce;
        expirationTime = block.timestamp + disputeDuration;

        emit DisputeStarted(msg.sender, currentNonce);
    }

    // 📌 Permite retirar fondos una vez que expire el período de disputa
    function withdrawFunds() public onlyParticipant {
        require(block.timestamp >= expirationTime, "El período de disputa aún no ha expirado");

        uint256 amount = accountBalances[msg.sender];
        accountBalances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Error al enviar fondos");

        emit FundsWithdrawn(msg.sender, amount);
    }
}
