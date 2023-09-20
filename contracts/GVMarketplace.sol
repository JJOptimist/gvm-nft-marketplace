// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NFTMarketplace is Ownable, IERC721Receiver {
    using SafeMath for uint256;

    ERC721 public nftContract;
    IERC20 public gvmToken; 
    uint256 public listingPrice = 1e18; 

    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    Listing[] public listings;

    event NFTListed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event NFTSold(address indexed seller, address indexed buyer, uint256 indexed tokenId, uint256 price);

    constructor(address _nftContract, address _gvmToken) {
        nftContract = ERC721(_nftContract);
        gvmToken = IERC20(_gvmToken);
    }

    function setListingPrice(uint256 _price) external onlyOwner {
        listingPrice = _price;
    }

    function listNFT(uint256 _tokenId, uint256 _price) external {
        require(msg.sender == nftContract.ownerOf(_tokenId), "You must own the NFT");
        require(_price >= listingPrice, "Listing price too low");
        require(nftContract.getApproved(_tokenId) == address(this), "Contract not approved");

        nftContract.safeTransferFrom(msg.sender, address(this), _tokenId);
        listings.push(Listing({
            seller: msg.sender,
            tokenId: _tokenId,
            price: _price,
            active: true
        }));

        emit NFTListed(msg.sender, _tokenId, _price);
    }

    function buyNFT(uint256 _listingIndex) external {
        require(_listingIndex < listings.length, "Listing does not exist");
        Listing storage listing = listings[_listingIndex];
        require(listing.active, "Listing is not active");

        gvmToken.transferFrom(msg.sender, listing.seller, listing.price);

        listing.active = false;
        nftContract.safeTransferFrom(address(this), msg.sender, listing.tokenId);

        emit NFTSold(listing.seller, msg.sender, listing.tokenId, listing.price);
    }

    function getActiveListings() external view returns (Listing[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 0; i < listings.length; i++) {
            if (listings[i].active) {
                activeCount++;
            }
        }

        Listing[] memory result = new Listing[](activeCount);
        uint256 resultIndex = 0;
        for (uint256 i = 0; i < listings.length; i++) {
            if (listings[i].active) {
                result[resultIndex] = listings[i];
                resultIndex++;
            }
        }

        return result;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
