// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SecureMultiWallet {
    // Eventos para registrar actividades dentro del contrato
    event FundsDeposited(address indexed sender, uint256 amount, uint256 newBalance);
    event TransactionProposed(
        address indexed proposer,
        uint256 indexed txnId,
        address indexed recipient,
        uint256 amount,
        bytes payload
    );
    event TransactionApproved(address indexed approver, uint256 indexed txnId);
    event ApprovalRevoked(address indexed revoker, uint256 indexed txnId);
    event TransactionExecuted(address indexed executor, uint256 indexed txnId);

    // Lista de miembros autorizados para gestionar fondos
    address[] public members;
    mapping(address => bool) public isMember;
    uint256 public minApprovalsRequired;

    // Estructura para gestionar transacciones
    struct Txn {
        address recipient;       // Dirección que recibirá los fondos
        uint256 amount;          // Monto a transferir
        bytes payload;           // Datos adicionales si es una llamada a contrato
        bool completed;          // Indica si ya se ejecutó
        uint256 approvals;       // Número de aprobaciones recibidas
    }

    // Mapeo para rastrear aprobaciones de cada miembro por transacción
    mapping(uint256 => mapping(address => bool)) public hasApproved;

    // Lista de transacciones en espera
    Txn[] public pendingTxns;

    // Modificador: Solo los miembros pueden ejecutar ciertas funciones
    modifier onlyMember() {
        require(isMember[msg.sender], "Access denied: Not a member");
        _;
    }

    // Modificador: Verifica que la transacción exista
    modifier txnExists(uint256 _txnId) {
        require(_txnId < pendingTxns.length, "Transaction does not exist");
        _;
    }

    // Modificador: Verifica que la transacción aún no se haya ejecutado
    modifier notCompleted(uint256 _txnId) {
        require(!pendingTxns[_txnId].completed, "Transaction already completed");
        _;
    }

    // Modificador: Verifica que el miembro aún no haya aprobado la transacción
    modifier notApproved(uint256 _txnId) {
        require(!hasApproved[_txnId][msg.sender], "Transaction already approved by this member");
        _;
    }

    // Constructor: Define los miembros y cuántas aprobaciones se necesitan
    constructor(address[] memory _members, uint256 _minApprovalsRequired) {
        require(_members.length > 0, "At least one member required");
        require(
            _minApprovalsRequired > 0 && _minApprovalsRequired <= _members.length,
            "Invalid number of required approvals"
        );

        for (uint256 i = 0; i < _members.length; i++) {
            address member = _members[i];

            require(member != address(0), "Invalid member address");
            require(!isMember[member], "Duplicate member detected");

            isMember[member] = true;
            members.push(member);
        }

        minApprovalsRequired = _minApprovalsRequired;
    }

    // Función para recibir depósitos en el contrato
    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value, address(this).balance);
    }

    // Proponer una transacción a ejecutar
    function proposeTransaction(address _recipient, uint256 _amount, bytes memory _payload)
        public
        onlyMember
    {
        uint256 txnId = pendingTxns.length;

        pendingTxns.push(
            Txn({
                recipient: _recipient,
                amount: _amount,
                payload: _payload,
                completed: false,
                approvals: 0
            })
        );

        emit TransactionProposed(msg.sender, txnId, _recipient, _amount, _payload);
    }

    // Aprobar una transacción
    function approveTransaction(uint256 _txnId)
        public
        onlyMember
        txnExists(_txnId)
        notCompleted(_txnId)
        notApproved(_txnId)
    {
        Txn storage txn = pendingTxns[_txnId];
        txn.approvals += 1;
        hasApproved[_txnId][msg.sender] = true;

        emit TransactionApproved(msg.sender, _txnId);
    }

    // Ejecutar una transacción si tiene suficientes aprobaciones
    function executeTransaction(uint256 _txnId)
        public
        onlyMember
        txnExists(_txnId)
        notCompleted(_txnId)
    {
        Txn storage txn = pendingTxns[_txnId];

        require(
            txn.approvals >= minApprovalsRequired,
            "Not enough approvals to execute transaction"
        );

        txn.completed = true;

        (bool success,) = txn.recipient.call{value: txn.amount}(txn.payload);
        require(success, "Transaction execution failed");

        emit TransactionExecuted(msg.sender, _txnId);
    }

    // Revocar la aprobación de una transacción antes de que se ejecute
    function revokeApproval(uint256 _txnId)
        public
        onlyMember
        txnExists(_txnId)
        notCompleted(_txnId)
    {
        require(hasApproved[_txnId][msg.sender], "You have not approved this transaction");

        Txn storage txn = pendingTxns[_txnId];
        txn.approvals -= 1;
        hasApproved[_txnId][msg.sender] = false;

        emit ApprovalRevoked(msg.sender, _txnId);
    }

    // Obtener la lista de miembros
    function getMembers() public view returns (address[] memory) {
        return members;
    }

    // Obtener el número de transacciones pendientes
    function getTransactionCount() public view returns (uint256) {
        return pendingTxns.length;
    }

    // Obtener información detallada de una transacción específica
    function getTransaction(uint256 _txnId)
        public
        view
        returns (
            address recipient,
            uint256 amount,
            bytes memory payload,
            bool completed,
            uint256 approvals
        )
    {
        Txn storage txn = pendingTxns[_txnId];

        return (
            txn.recipient,
            txn.amount,
            txn.payload,
            txn.completed,
            txn.approvals
        );
    }
}