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

    /*
     *  Structs
     */
    struct PotionState {
        uint256 estimatePrice;
        uint256 boughtLifeTime;
        uint256 availablePotionFund;
        bool isDead;
        uint256 lastUpdateTime;
    }

    mapping (uint256 => PotionState) public tokenId2PotionState;

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

    function startHabergPotionModel(uint256 _tokenId, uint256 _estimatePrice, uint256 _ringAmount) public {
        require(
            ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId) == msg.sender, "Only apostle owner can start Potion model.");

        require(tokenId2PotionState[_tokenId].lastUpdateTime == 0, "Potion model should not started yet.");
        require(_estimatePrice > 0, "Apostle estimated price must larger than zero.");

        ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(msg.sender, address(this), _ringAmount);

        tokenId2PotionState[_tokenId] = PotionState({
            estimatePrice: _estimatePrice,
            boughtLifeTime: 0,
            availablePotionFund: _ringAmount,
            isDead: false,
            lastUpdateTime: now
        });
    }

    // deposit haberg tax
    function buyPotion(uint256 _tokenId, uint256 _ringAmount) public {
        require(ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId) == msg.sender, "Only apostle owner can buy potion.");
        require(tokenId2PotionState[_tokenId].lastUpdateTime > 0, "Potion model does not exist.");
        require(!tokenId2PotionState[_tokenId].isDead, "Apostle must not be dead.");

        ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(msg.sender, address(this), _ringAmount);

        tokenId2PotionState[_tokenId].availablePotionFund += _ringAmount;
    }

    function changeHabergEstimatePrice(uint256 _tokenId, uint256 _estimatePrice) public {
        require(ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId) == msg.sender);
        require(tokenId2PotionState[_tokenId].lastUpdateTime > 0, "Potion model does not exist.");
        require(!tokenId2PotionState[_tokenId].isDead, "Apostle must not be dead.");

        _updateHabergPotionState(_tokenId);

        tokenId2PotionState[_tokenId].estimatePrice = _estimatePrice;
    }

    function _updateHabergPotionState(uint256 _tokenId) internal {
        uint256 newBoughtLifeTime = now - tokenId2PotionState[_tokenId].lastUpdateTime;

        tokenId2PotionState[_tokenId].availablePotionFund = tokenId2PotionState[_tokenId].availablePotionFund.sub(
            tokenId2PotionState[_tokenId].estimatePrice.mul(registry.uintOf(UINT_HABERG_POTION_TAX_RATE)).div(100000000).mul(newBoughtLifeTime).div(1 days)
        );

        tokenId2PotionState[_tokenId].boughtLifeTime += newBoughtLifeTime;

        tokenId2PotionState[_tokenId].lastUpdateTime = now;
    }

    function stopHabergAndWithdrawFunds(uint256 _tokenId) public {
        require(ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId) == msg.sender, "Only apostle owner can call this.");
        require(tokenId2PotionState[_tokenId].lastUpdateTime > 0, "Potion model does not exist.");
        require(!tokenId2PotionState[_tokenId].isDead, "Apostle must not be dead.");

        _updateHabergPotionState(_tokenId);

        tokenId2PotionState[_tokenId].isDead = true;
        tokenId2PotionState[_tokenId].availablePotionFund = 0;
        
        ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(
            address(this), msg.sender, tokenId2PotionState[_tokenId].availablePotionFund);
    }

    function forceBuy(uint256 _tokenId, uint256 _depositPotionFee) public {
        require(tokenId2PotionState[_tokenId].lastUpdateTime > 0, "Potion model does not exist.");
        require(!tokenId2PotionState[_tokenId].isDead, "Apostle must not be dead.");

        address tokenOwner = ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId);
        ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(
            msg.sender, tokenOwner, tokenId2PotionState[_tokenId].estimatePrice);

        // must approve this first, if not, others can kill this apostle in Apostle.
        ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).transferFrom(tokenOwner, msg.sender, _tokenId);

        _updateHabergPotionState(_tokenId);

        ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(
            address(this), tokenOwner, tokenId2PotionState[_tokenId].availablePotionFund);

        buyPotion(_tokenId, _depositPotionFee);
    }

    function harbergLiftTime(uint256 _tokenId) public view returns (uint256) {
        return tokenId2PotionState[_tokenId].boughtLifeTime + tokenId2PotionState[_tokenId].availablePotionFund
            .mul(1 days).div(
            tokenId2PotionState[_tokenId].estimatePrice.mul(registry.uintOf(UINT_HABERG_POTION_TAX_RATE)).div(100000000)
            );
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
