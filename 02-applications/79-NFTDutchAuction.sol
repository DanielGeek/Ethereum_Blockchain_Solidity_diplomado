// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface INFT {
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
}

contract NFTDutchAuction {
    // 🔹 Duracion fija de la subasta: 7 días
    uint256 private constant AUCTION_DURATION = 7 days;

    // 📌 Datos del NFT en subasta
    INFT public immutable nft;
    uint256 public immutable tokenId;

    // 📌 Datos del vendedor y subasta
    address payable public immutable seller;
    uint256 public immutable initialPrice;
    uint256 public immutable auctionStartTime;
    uint256 public immutable auctionEndTime;
    uint256 public immutable priceReductionRate;

    // 📌 Constructor: Configura la subasta con el precio inicial y la tasa de descuento
    constructor(
        uint256 _initialPrice,
        uint256 _priceReductionRate,
        address _nftAddress,
        uint256 _tokenId
    ) {
        seller = payable(msg.sender);
        initialPrice = _initialPrice;
        auctionStartTime = block.timestamp;
        auctionEndTime = block.timestamp + AUCTION_DURATION;
        priceReductionRate = _priceReductionRate;

        require(
            _initialPrice >= _priceReductionRate * AUCTION_DURATION,
            "El precio inicial es demasiado bajo"
        );

        nft = INFT(_nftAddress);
        tokenId = _tokenId;
    }

    // 📌 Calcula el precio actual basado en el tiempo transcurrido
    function getCurrentPrice() public view returns (uint256) {
        uint256 elapsed = block.timestamp - auctionStartTime;
        uint256 discount = priceReductionRate * elapsed;
        return initialPrice - discount;
    }

    // 📌 Permite a un comprador adquirir el NFT al precio actual
    function purchaseNFT() external payable {
        require(block.timestamp < auctionEndTime, "La subasta ha expirado");

        uint256 currentPrice = getCurrentPrice();
        require(msg.value >= currentPrice, "ETH insuficiente para comprar el NFT");

        // 🔹 Transfiere el NFT al comprador
        nft.transferFrom(seller, msg.sender, tokenId);

        // 🔹 Reembolsa el exceso de ETH si el comprador pago mas del precio actual
        uint256 excessAmount = msg.value - currentPrice;
        if (excessAmount > 0) {
            payable(msg.sender).transfer(excessAmount);
        }

        // 🔹 Finaliza la subasta destruyendo el contrato y enviando los fondos al vendedor
        selfdestruct(seller);
    }
}
