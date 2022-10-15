// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./BasicLicense.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

error FundMe__NotOwner();

contract LicenseFactory{
    
    using PriceConverter for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _licenseIds;

    uint256 public constant MINIMUM_USD = 50 * 10**18;
    address private immutable i_owner;
    address[] private s_licenseOwners;
    mapping(address => uint256) private s_addressToNumberOfLicense;
    AggregatorV3Interface private s_priceFeed;
    BasicLicense[] public s_basicLicenseArray;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address priceFeed) {
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    function buyLicense() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "License price is Higher!"
        );
        _licenseIds.increment();
        uint256 newLicenseID = _licenseIds.current();
        BasicLicense basicLicense = new BasicLicense(msg.sender, newLicenseID);
        s_basicLicenseArray.push(basicLicense);
        s_addressToNumberOfLicense[msg.sender] += 1;
        s_licenseOwners.push(msg.sender);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getAddressToNumberOfLicense(address licenseOwnerAddress)
        public
        view
        returns (uint256)
    {
        return s_addressToNumberOfLicense[licenseOwnerAddress];
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getLicense(uint256 index) public view returns (address) {
        return s_basicLicenseArray[index].getOwner();
    }
    function getLicenseOwners(uint256 index) public view returns (address) {
        return s_licenseOwners[index];
    }
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
