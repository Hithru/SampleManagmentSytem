// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "base64-sol/base64.sol";
import "hardhat/console.sol";

error ERC721Metadata__URI_QueryFor_NonExistentToken();
error TokenLicense__TransferFailed();
error TokenLicense__NeedMoreETHSent();

contract TokenLicense is ERC721,Ownable{

    uint256 private s_tokenCounter;
    uint256 private i_licensePrice;
    string private i_companyName;

    AggregatorV3Interface internal immutable i_priceFeed;

    event CreatedLicenseToken(uint256 indexed tokenId, uint256 licensePrice);

    constructor(
        address priceFeedAddress,
        uint256  licensePrice,
        string memory companyName
    ) ERC721("Software License", "SHK") {
        s_tokenCounter = 0;
        i_priceFeed = AggregatorV3Interface(priceFeedAddress);
        i_licensePrice = licensePrice;
        i_companyName = companyName;
    }


    function mintToken() public payable  {
        if (msg.value < i_licensePrice) {
            revert TokenLicense__NeedMoreETHSent();
        }
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        emit CreatedLicenseToken(s_tokenCounter, i_licensePrice);
    }



    function _baseURI() internal pure override returns (string memory) {

        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert ERC721Metadata__URI_QueryFor_NonExistentToken();
        }
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                i_companyName, // You can add whatever name here
                                '", "description":"An License for the software", ',
                                '"attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                                'https://gateway.pinata.cloud/ipfs/QmSL812BUqiA1nuoA9JGUo9gg4t42tTxUe5sdZZQnA8VEC',
                                '"}'
                            )
                        )
                    )
                )
            );
    }



    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert TokenLicense__TransferFailed();
        }
    }
}