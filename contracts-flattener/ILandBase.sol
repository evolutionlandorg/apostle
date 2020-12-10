// Root file: contracts/interfaces/ILandBase.sol

pragma solidity ^0.4.24;

contract ILandBase {

    function resourceToken2RateAttrId(address _resourceToken) public view returns (uint256);
}