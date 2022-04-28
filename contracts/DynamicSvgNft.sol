//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "base64-sol/base64.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract DynamicSvgNft is ERC721 {
    uint256 public s_tokenCounter;
    string public s_lowImageURI;
    string public s_highImageURI;
    int256 public immutable i_highValue;
    AggregatorV3Interface public immutable i_priceFeed;

    constructor (int256 highValue, string memory lowSVG, string memory highSVG, address priceFeedAddress)
    ERC721("Dynamic SVG NFT", "DSN") {
        s_tokenCounter = 0;
        s_lowImageURI = svgToImageURI(lowSVG);
        s_highImageURI = svgToImageURI(highSVG);
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_highValue = highValue;
    }

    function svgToImageURI(string memory svg) public pure returns(string memory){
        string memory baseImageURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseImageURL, svgBase64Encoded));
    } 

    function mintNft() external {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
    }

    function _baseURI() internal pure override returns (string memory){
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        (,int256 price, ,,) = i_priceFeed.latestRoundData();
        string memory imageURI = s_lowImageURI;
        if (price > i_highValue) {
            imageURI = s_highImageURI;
        }
        
        bytes memory metaDataTemplate = (
            abi.encodePacked(
                '{"name": "Dynamic SVG", "description": "A cool NFT!", "attributes": [{"trait_type":"coolness","value":100}],"image":"',
                imageURI,
                '"}'
            )
        );
        bytes memory metaDataTemplateBytes = bytes(metaDataTemplate);
        string memory encodedMetadata = Base64.encode(metaDataTemplateBytes);
        return (string(abi.encodePacked(_baseURI(), encodedMetadata)));
    }
}