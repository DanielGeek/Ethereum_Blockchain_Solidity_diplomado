// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 🔹 Interfaz para interactuar con un token ERC20
interface IToken {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

contract TokenCrowdFunding {
    // 📌 Eventos para registrar las acciones de la campaña
    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed organizer,
        uint256 fundingGoal,
        uint32 startTimestamp,
        uint32 endTimestamp
    );
    event CampaignCancelled(uint256 indexed campaignId);
    event ContributionMade(uint256 indexed campaignId, address indexed contributor, uint256 amount);
    event ContributionWithdrawn(uint256 indexed campaignId, address indexed contributor, uint256 amount);
    event FundsClaimed(uint256 indexed campaignId);
    event RefundProcessed(uint256 indexed campaignId, address indexed contributor, uint256 amount);

    // 📌 Estructura que representa cada campaña de financiamiento
    struct Campaign {
        address organizer; // 🔹 Persona que creó la campaña
        uint256 fundingGoal; // 🔹 Monto objetivo a recaudar
        uint256 totalContributed; // 🔹 Total de fondos recaudados
        uint32 startTimestamp; // 🔹 Momento en que inicia la campaña
        uint32 endTimestamp; // 🔹 Momento en que finaliza la campaña
        bool fundsClaimed; // 🔹 Indica si el organizador ya reclamó los fondos
    }

    // 📌 Token ERC20 utilizado para las contribuciones
    IToken public immutable fundingToken;
    
    // 🔹 Contador de campañas creadas (también sirve como ID de campañas)
    uint256 public campaignCounter;

    // 🔹 Mapeo de ID de campañas a su respectiva estructura
    mapping(uint256 => Campaign) public campaigns;

    // 🔹 Mapeo de contribuciones realizadas por cada usuario a cada campaña
    mapping(uint256 => mapping(address => uint256)) public contributions;

    constructor(address _tokenAddress) {
        fundingToken = IToken(_tokenAddress);
    }

    // 📌 Crear una nueva campaña de financiamiento
    function createCampaign(uint256 _goal, uint32 _start, uint32 _end) external {
        require(_start >= block.timestamp, "La campaia no puede iniciar en el pasado");
        require(_end >= _start, "La fecha de finalizacion debe ser despues del inicio");
        require(_end <= block.timestamp + 90 days, "Duracion maxima superada");

        campaignCounter += 1;
        campaigns[campaignCounter] = Campaign({
            organizer: msg.sender,
            fundingGoal: _goal,
            totalContributed: 0,
            startTimestamp: _start,
            endTimestamp: _end,
            fundsClaimed: false
        });

        emit CampaignCreated(campaignCounter, msg.sender, _goal, _start, _end);
    }

    // 📌 Cancelar una campaña antes de su inicio
    function cancelCampaign(uint256 _campaignId) external {
        Campaign memory campaign = campaigns[_campaignId];
        require(campaign.organizer == msg.sender, "Solo el organizador puede cancelar");
        require(block.timestamp < campaign.startTimestamp, "La campania ya ha comenzado");

        delete campaigns[_campaignId];
        emit CampaignCancelled(_campaignId);
    }

    // 📌 Contribuir con tokens a una campaña activa
    function contribute(uint256 _campaignId, uint256 _amount) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp >= campaign.startTimestamp, "La campania aun no ha comenzado");
        require(block.timestamp <= campaign.endTimestamp, "La campania ha finalizado");

        campaign.totalContributed += _amount;
        contributions[_campaignId][msg.sender] += _amount;
        fundingToken.transferFrom(msg.sender, address(this), _amount);

        emit ContributionMade(_campaignId, msg.sender, _amount);
    }

    // 📌 Retirar una contribución antes de que la campaña finalice
    function withdrawContribution(uint256 _campaignId, uint256 _amount) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp <= campaign.endTimestamp, "La campania ha finalizado");

        campaign.totalContributed -= _amount;
        contributions[_campaignId][msg.sender] -= _amount;
        fundingToken.transfer(msg.sender, _amount);

        emit ContributionWithdrawn(_campaignId, msg.sender, _amount);
    }

    // 📌 Reclamar los fondos si la campaña alcanzó su objetivo
    function claimFunds(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        require(campaign.organizer == msg.sender, "Solo el organizador puede reclamar los fondos");
        require(block.timestamp > campaign.endTimestamp, "La campania aun no ha finalizado");
        require(campaign.totalContributed >= campaign.fundingGoal, "La campania no alcanzo su objetivo");
        require(!campaign.fundsClaimed, "Los fondos ya han sido reclamados");

        campaign.fundsClaimed = true;
        fundingToken.transfer(campaign.organizer, campaign.totalContributed);

        emit FundsClaimed(_campaignId);
    }

    // 📌 Procesar reembolsos si la campaña no alcanzó su meta
    function requestRefund(uint256 _campaignId) external {
        Campaign memory campaign = campaigns[_campaignId];
        require(block.timestamp > campaign.endTimestamp, "La campania aun no ha finalizado");
        require(campaign.totalContributed < campaign.fundingGoal, "La campania alcanzo su objetivo");

        uint256 refundAmount = contributions[_campaignId][msg.sender];
        contributions[_campaignId][msg.sender] = 0;
        fundingToken.transfer(msg.sender, refundAmount);

        emit RefundProcessed(_campaignId, msg.sender, refundAmount);
    }
}
