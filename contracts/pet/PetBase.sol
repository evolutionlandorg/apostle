pragma solidity ^0.4.24;

import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/interfaces/INFTAdaptor.sol";
import "@evolutionland/common/contracts/interfaces/IInterstellarEncoderV3.sol";
import "../interfaces/IApostleBase.sol";
import "../interfaces/IERC721Bridge.sol";
import "../interfaces/IGeneScience.sol";
import "../interfaces/ILandResource.sol";
import "../ApostleSettingIds.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "@evolutionland/common/contracts/PausableDSAuth.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";

contract PetBase is PausableDSAuth, ApostleSettingIds {

    using SafeMath for *;

    /*
     *  Storage
    */
    bool private singletonLock = false;

    ISettingsRegistry public registry;

    uint128 public lastPetObjectId;

    uint128 public maxTiedNumber;

    struct PetStatus {
        uint128 maxTiedNumber;
        uint128 tiedCount;
        uint256[] tiedList;
    }

    struct TiedStatus {
        uint256 apostleTokenId;
        uint256 index;
    }

    mapping(uint256 => PetStatus) public tokenId2PetStatus;
    mapping(uint256 => TiedStatus) public pet2TiedStatus;

    event Tied(uint256 apostleTokenId, uint256 mirrorTokenId, uint256 enhancedTalents, bool changed, address originNFT, address owner);
    event UnTied(uint256 apostleTokenId, uint256 mirrorTokenId, uint256 enhancedTalents, bool changed, address originNFT, address owner);

    /*
        *  Modifiers
        */
    modifier singletonLockCall() {
        require(!singletonLock, "Only can call once");
        _;
        singletonLock = true;
    }

    function initializeContract(ISettingsRegistry _registry, uint128 _number) public singletonLockCall {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
        registry = _registry;
        maxTiedNumber = _number;
    }


    // TODO: it can be more specific afterwards
    function createPet(address _owner) public auth returns (uint256) {

        lastPetObjectId += 1;
        require(lastPetObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");
        uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(_owner, uint128(lastPetObjectId));

        return tokenId;
    }

     function bridgeInAndTie(address _originNftAddress, uint256 _originTokenId, uint256 _apostleTokenId) public {
         address erc721Bridge = registry.addressOf(SettingIds.CONTRACT_ERC721_BRIDGE);
         uint256 mirrorTokenId = IERC721Bridge(erc721Bridge).bridgeInAuth(_originNftAddress, _originTokenId, msg.sender);
         _tiePetTokenToApostle(mirrorTokenId, _apostleTokenId, msg.sender, _originNftAddress);
     }




    // any one can use it
    function tiePetTokenToApostle(uint256 _mirrorTokenId, uint256 _apostleTokenId) public {
        IInterstellarEncoderV3 interstellarEncoder = IInterstellarEncoderV3(registry.addressOf(SettingIds.CONTRACT_INTERSTELLAR_ENCODER));
        address originAddress = interstellarEncoder.getOriginAddress(_mirrorTokenId);

        _tiePetTokenToApostle(_mirrorTokenId, _apostleTokenId, msg.sender, originAddress);
    }


    function _tiePetTokenToApostle(uint256 _petTokenId, uint256 _apostleTokenId, address _owner, address _originAddress) internal {
        if (tokenId2PetStatus[_apostleTokenId].maxTiedNumber == 0) {
            tokenId2PetStatus[_apostleTokenId].maxTiedNumber = maxTiedNumber;
        }

        require(pet2TiedStatus[_petTokenId].apostleTokenId == 0, "it has already been tied.");
        tokenId2PetStatus[_apostleTokenId].tiedCount += 1;
        require(tokenId2PetStatus[_apostleTokenId].tiedCount <= tokenId2PetStatus[_apostleTokenId].maxTiedNumber);

        uint256 index = tokenId2PetStatus[_apostleTokenId].tiedList.length;
        tokenId2PetStatus[_apostleTokenId].tiedList.push(_petTokenId);

        pet2TiedStatus[_petTokenId] = TiedStatus({
            apostleTokenId : _apostleTokenId,
            index : index
            });


        // TODO: update gene, through apostleBase
        address apostleBase = registry.addressOf(ApostleSettingIds.CONTRACT_APOSTLE_BASE);
        uint256 talents;
        uint256 genes;
        (genes, talents, ,,,,,,,) = IApostleBase(apostleBase).getApostleInfo(_apostleTokenId);
        uint256 enhancedTalents = IGeneScience(registry.addressOf(CONTRACT_GENE_SCIENCE)).enhanceWithMirrorToken(talents, _petTokenId);

        bool changed = _updateTalentsAndMinerStrength(_petTokenId, _apostleTokenId, genes, talents, enhancedTalents, _owner);

        emit Tied(_apostleTokenId, _petTokenId, enhancedTalents, changed, _originAddress, _owner);
    }


    function _updateTalentsAndMinerStrength(uint256 _petTokenId, uint256 _apostleTokenId, uint256 _genes, uint256 _talents, uint256 _modifiedTalents, address _owner) internal returns (bool){
        address erc721Bridge = registry.addressOf(SettingIds.CONTRACT_ERC721_BRIDGE);
        IInterstellarEncoderV3 interstellarEncoder = IInterstellarEncoderV3(registry.addressOf(SettingIds.CONTRACT_INTERSTELLAR_ENCODER));

        // if the pet is from outside world
        // it need to be bridged in
        if (interstellarEncoder.getProducerId(_petTokenId) >= 256) {

            require(IERC721Bridge(erc721Bridge).isBridged(_petTokenId), "please bridged in first.");
        }

        // if this pet is inside evoland
        // it will also be considered in erc721Bridge
        require(IERC721Bridge(erc721Bridge).ownerOf(_petTokenId) == _owner, "you have no right.");
        // msg.sender must own this apostle
        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        require(ERC721(objectOwnership).ownerOf(_apostleTokenId) == _owner, "you have no right to touch this apostle.");


        // TODO: update mine
        // changed - true
        bool changed = _talents == _modifiedTalents ? false : true;
        if (changed) {
            address landResource = registry.addressOf(CONTRACT_LAND_RESOURCE);
            if (ILandResource(landResource).landWorkingOn(_apostleTokenId) != 0) {
                // true means minus strength
                ILandResource(landResource).updateMinerStrengthWhenStop(_apostleTokenId, _owner);
            }

            IApostleBase(registry.addressOf(CONTRACT_APOSTLE_BASE)).updateGenesAndTalents(_apostleTokenId, _genes, _modifiedTalents);

            if (ILandResource(landResource).landWorkingOn(_apostleTokenId) != 0) {
                ILandResource(landResource).updateMinerStrengthWhenStart(_apostleTokenId, _owner);
            }
        }

        return changed;
    }

    function untiePetToken(uint256 _petTokenId) public {
        uint256 apostleTokenId = pet2TiedStatus[_petTokenId].apostleTokenId;
        require(apostleTokenId != 0, "no need to untie.");

        uint256 index = pet2TiedStatus[_petTokenId].index;
        // update count
        tokenId2PetStatus[apostleTokenId].tiedCount = uint128(uint256(tokenId2PetStatus[apostleTokenId].tiedCount).sub(1));

        // update petList
        uint256 lastPetIndex = uint128(tokenId2PetStatus[apostleTokenId].tiedList.length.sub(1));
        uint256 lastPet = tokenId2PetStatus[apostleTokenId].tiedList[lastPetIndex];

        tokenId2PetStatus[apostleTokenId].tiedList[index] = lastPet;
        tokenId2PetStatus[apostleTokenId].tiedList[lastPetIndex] = 0;

        tokenId2PetStatus[apostleTokenId].tiedList.length -= 1;

        // update lastPet's index
        pet2TiedStatus[lastPet].index = index;

        delete pet2TiedStatus[_petTokenId];


        address apostleBase = registry.addressOf(ApostleSettingIds.CONTRACT_APOSTLE_BASE);
        uint256 talents;
        uint256 genes;
        (genes, talents, ,,,,,,,) = IApostleBase(apostleBase).getApostleInfo(apostleTokenId);
        uint256 weakenTalents = IGeneScience(registry.addressOf(CONTRACT_GENE_SCIENCE)).removeMirrorToken(talents, _petTokenId);


        bool changed = _updateTalentsAndMinerStrength(_petTokenId, apostleTokenId, genes, talents, weakenTalents, msg.sender);

        IInterstellarEncoderV3 interstellarEncoder = IInterstellarEncoderV3(registry.addressOf(SettingIds.CONTRACT_INTERSTELLAR_ENCODER));
        address originAddress = interstellarEncoder.getOriginAddress(_petTokenId);

        emit UnTied(apostleTokenId, _petTokenId, weakenTalents, changed, originAddress, msg.sender);

    }

}
