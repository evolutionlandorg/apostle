pragma solidity ^0.4.24;

interface IItemBase {
	function getBaseInfo(uint256 _tokenId) external view returns (uint16, uint16, uint16);
	function getPrefer(uint256 _tokenId) external view returns (uint16);
}
