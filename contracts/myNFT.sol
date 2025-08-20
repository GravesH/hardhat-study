// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract myNFT is  Ownable,ERC721URIStorage {
    uint256 public tokenCounter=1;
    constructor() ERC721("MyNFT", "HZYNFT") {
    }
    //铸造合约，只有合约所有者可以调用
    function safeMint(address to,string memory tokenURL) external  onlyOwner {
        // 在链上 安全地创造并分配一个新的 NFT 给某个地址
        //mint本意是铸造   可以理解为铸造币的意思
        _safeMint(to, tokenCounter);
        _setTokenURI(tokenCounter, tokenURL); // 👈 给 NFT 绑定元数据
        tokenCounter++;
    }
}