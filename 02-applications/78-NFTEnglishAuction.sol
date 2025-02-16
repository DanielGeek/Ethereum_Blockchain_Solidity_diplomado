// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface INFT {
    function safeTransferFrom(address from, address to, uint256 tokenId)
        external;
    function transferFrom(address, address, uint256) external;
}

contract NFTEnglishAuction {
    // 🔹 Eventos para seguimiento de la subasta
    event AuctionStarted();
    event NewBid(address indexed bidder, uint256 amount);
    event FundsWithdrawn(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 finalBid);

    // 📌 Datos del NFT en subasta
    INFT public nft;
    uint256 public nftTokenId;

    // 📌 Datos del vendedor y de la subasta
    address payable public owner;
    uint256 public auctionEndTime;
    bool public auctionActive;
    bool public auctionFinished;

    // 📌 Información de la oferta más alta
    address public topBidder;
    uint256 public topBid;
    mapping(address => uint256) public pendingWithdrawals;

    // 📌 Constructor: Inicializa la subasta con el NFT y el precio inicial
    constructor(address _nftAddress, uint256 _tokenId, uint256 _initialBid) {
        nft = INFT(_nftAddress);
        nftTokenId = _tokenId;

        owner = payable(msg.sender);
        topBid = _initialBid;
    }

    // 📌 Inicia la subasta transfiriendo el NFT al contrato
    function launchAuction() external {
        require(!auctionActive, "La subasta ya comenzo");
        require(msg.sender == owner, "Solo el vendedor puede iniciar la subasta");

        nft.transferFrom(msg.sender, address(this), nftTokenId);
        auctionActive = true;
        auctionEndTime = block.timestamp + 7 days; // La subasta dura 7 días

        emit AuctionStarted();
    }

    // 📌 Permite a los usuarios hacer ofertas por el NFT
    function placeBid() external payable {
        require(auctionActive, "La subasta aun no ha comenzado");
        require(block.timestamp < auctionEndTime, "La subasta ha terminado");
        require(msg.value > topBid, "La oferta debe ser mayor a la actual");

        // 🔹 Si ya había un postor anterior, almacenamos su oferta para que pueda retirarla
        if (topBidder != address(0)) {
            pendingWithdrawals[topBidder] += topBid;
        }

        topBidder = msg.sender;
        topBid = msg.value;

        emit NewBid(msg.sender, msg.value);
    }

    // 📌 Permite a un postor retirar su dinero si fue superado
    function withdrawFunds() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit FundsWithdrawn(msg.sender, amount);
    }

    // 📌 Finaliza la subasta y transfiere el NFT al ganador
    function finalizeAuction() external {
        require(auctionActive, "La subasta aun no ha iniciado");
        require(block.timestamp >= auctionEndTime, "La subasta no ha finalizado");
        require(!auctionFinished, "La subasta ya ha sido finalizada");

        auctionFinished = true;

        if (topBidder != address(0)) {
            // 🔹 Transferimos el NFT al ganador y enviamos el pago al vendedor
            nft.safeTransferFrom(address(this), topBidder, nftTokenId);
            owner.transfer(topBid);
        } else {
            // 🔹 Si nadie ofertó, devolvemos el NFT al vendedor
            nft.safeTransferFrom(address(this), owner, nftTokenId);
        }

        emit AuctionEnded(topBidder, topBid);
    }
}
