// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTCreator is ERC721Enumerable, Ownable {
    string private _baseTokenURI;

    constructor(string memory name, string memory symbol, string memory baseTokenURI) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;
    }

    function setBaseURI(string memory newBaseTokenURI) external onlyOwner {
        _baseTokenURI = newBaseTokenURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    modifier onlyOwnerOf(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        _;
    }

    function mintNFT(address to) external onlyOwner returns (uint256) {
        uint256 tokenId = totalSupply() + 1; // Increment tokenId based on totalSupply
        _mint(to, tokenId);
        return tokenId;
    }

    function transferOwnership(address newOwner, uint256 tokenId) external onlyOwnerOf(tokenId) {
        _transfer(ownerOf(tokenId), newOwner, tokenId);
    }
}
