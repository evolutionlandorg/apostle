pragma solidity ^0.4.24;

interface ICraftBase {
    function getMetaData(uint256 tokenId) external view returns (uint, uint, uint, uint);
}
