pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/interfaces/IBurnableERC20.sol";
import "@evolutionland/common/contracts/interfaces/IMintableERC20.sol";
import "@evolutionland/common/contracts/DSAuth.sol";
import "./ApostleSettingIds.sol";

contract  HabergPotionShop is DSAuth, ApostleSettingIds {
    using SafeMath for *;

    /*
     *  Events
     */
    event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);

    /*
     *  Storages
     */

    bool private singletonLock = false;


    ISettingsRegistry public registry;

    mapping (uint256 => uint256) public tokenId2BoughtLifeTime;

    mapping (uint256 => uint256) public tokneId2AvailablePotionFund;

    mapping (uint256 => uint256) public tokenId2EstimatePrice;

    mapping (uint256 => uint256) public tokenId2LastUpdateTime;

    /*
     *  Modifiers
     */
    modifier singletonLockCall() {
        require(!singletonLock, "Only can call once");
        _;
        singletonLock = true;
    }


    /**
     * @dev Bank's constructor which set the token address and unitInterest_
     */
    constructor () public {
        // initializeContract(_registry);
    }

    /**
     * @dev Same with constructor, but is used and called by storage proxy as logic contract.
     * @param _registry - address of SettingsRegistry
     */
    function initializeContract(address _registry) public singletonLockCall {
        // call Ownable's constructor
        owner = msg.sender;

        emit LogSetOwner(msg.sender);

        registry = ISettingsRegistry(_registry);
    }

    // deposit haberg tax
    function buyPotion(uint256 _tokenId, uint256 _ringAmount) public {
        require(ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId) == msg.sender);

    }

    function startHabergPotionModel(uint256 _tokenId, uint256 _estimatePrice, uint256 _ringAmount) public {
        require(ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId) == msg.sender);

    }

    function changeHabergEstimatePrice(uint256 _tokenId, uint256 _estimatePrice) public {
        require(ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId) == msg.sender);

        tokenId2EstimatePrice[_tokenId] = _estimatePrice;

        _updateHabergPotionState(_tokenId);
    }

    function _updateHabergPotionState(uint256 _tokenId) internal {
        uint256 newBoughtLifeTime = now - tokenId2LastUpdateTime[_tokenId];

        tokneId2AvailablePotionFund[_tokenId] = tokneId2AvailablePotionFund[_tokenId].sub(
            tokenId2EstimatePrice[_tokenId].mul(registry.uintOf(UINT_HABERG_POTION_TAX_RATE)).div(100000000).mul(newBoughtLifeTime).div(1 days)
        );

        tokenId2BoughtLifeTime[_tokenId] += newBoughtLifeTime;

        tokenId2LastUpdateTime[_tokenId] = now;
    }

    function stopHabergAndWithdrawFunds(uint256 _tokenId) public {

    }

    function forceBuy(uint256 _tokenId) public {
        address tokenOwner = ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId);
        ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(
            msg.sender, tokenOwner, tokenId2EstimatePrice[_tokenId]);

        // must approve this first, if not, others can kill this apostle in Apostle.
        ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).transferFrom(tokenOwner, msg.sender, _tokenId);
    }

    function harbergLiftTime(uint256 _tokenId) public view returns (uint256) {
        return tokenId2BoughtLifeTime[_tokenId] + tokneId2AvailablePotionFund[_tokenId].mul(1 days).div(
            tokenId2EstimatePrice[_tokenId].mul(registry.uintOf(UINT_HABERG_POTION_TAX_RATE)).div(100000000));
    }

    /// @notice This method can be used by the owner to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }
        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(owner, balance);

        emit ClaimedTokens(_token, owner, balance);
    }

}
