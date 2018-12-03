pragma solidity ^0.4.24;


// TODO: update common-contract version then delete this.
contract ITokenUse {
    function registerTokenStatus(uint256 _tokenId, address _owner, address _user, uint256 _startTime, uint256 _endTime, uint256 _price, address _acceptedActivity) public;

    function startActivity(uint256 _tokenId, address _user) public;

    function stopActivity(uint256 _tokenId, address _user) public;

    function isObjectInUseStage(uint256 _tokenId) public view returns (bool);

    function isObjectReadyToUse(uint256 _tokenId) public view returns (bool);
}