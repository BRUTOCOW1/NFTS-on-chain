pragma solidity ^0.8.7;

import "@openzeppelin/contract/token/ERC721/ERC721.sol";
import "base64-sol/base64.sol";

contract DynamicSvgNft is ERC721 {
    uint256 public s_tokenCounter;

    constructor (string memory lowSVG, string memory highSVG) ERC721("Dynamic SVG NFT", "DSN") {}

    function mintNft() external {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    funciton _baseURI() internal pure override returns (string memory){
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        string memory metaDataTemplate = '{"name": "Dynamic SVG", "description": "A cool NFT!", "attributes": [{"trait_type":"coolness","value":100}],"image":"????"}';
        bytes memory metaDataTemplateBytes = bytes(metaDataTemplate);
        string memory encodedMetadata = Base64.encode(metaDataTemplateBytes);
        return (string(abi.encodePacked(_baseURI(), encodedMetadata)))
    }
}