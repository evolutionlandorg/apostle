pragma solidity ^0.4.23;

contract ILandResource {
    function updateMinerStrength(uint256 _apostleTokenId, address _landOwner, bool _isStop) public;

    function landWorkingOn(uint256 _apostleTokenId) public view returns (uint256);
}
