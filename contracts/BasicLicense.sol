// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17; 

contract BasicLicense{


    address private immutable i_owner;
    uint256 private immutable i_licenseId;

    constructor(address owner,uint256 licenseId) {
        i_owner = owner;
        i_licenseId = licenseId;
    }
    function getOwner() public view returns (address) {
        return i_owner;
    }

}
