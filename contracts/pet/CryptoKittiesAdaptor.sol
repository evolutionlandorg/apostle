pragma solidity ^0.4.24;

import "@evolutionland/common/contracts/ERC721Adaptor.sol";
import "../interfaces/IApostleBase.sol";
import "../interfaces/IGeneScience.sol";
import "../interfaces/ILandResource.sol";
import "../ApostleSettingIds.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract CryptoKittiesAdaptor is ApostleSettingIds, ERC721Adaptor {

    using SafeMath for *;

    uint128 public maxTiedNumber;

    // storage
    struct PetStatus {
        uint128 maxTiedNumber;
        uint128 tiedCount;
        uint256[] tiedList;
    }

    struct TiedStatus {
        uint256 apostleTokenId;
        uint256 index;
    }

    mapping(uint256 => PetStatus) tokenId2PetStatus;
    mapping(uint256 => TiedStatus) pet2TiedStatus;

    event Tied(uint256 apostleTokenId, uint256 mirrorTokenId, uint256 enhancedTalents, bool changed);
    event UnTied(uint256 apostleTokenId, uint256 mirrorTokenId, uint256 enhancedTalents, bool changed);


    function setMaxTiedNumber(uint128 _number) public onlyOwner {
        maxTiedNumber = _number;
    }


    function tieMirrorTokenToApostle(uint256 _mirrorTokenId, uint256 _apostleTokenId, address _owner) public auth {

        if(tokenId2PetStatus[_apostleTokenId].maxTiedNumber == 0) {
            tokenId2PetStatus[_apostleTokenId].maxTiedNumber = maxTiedNumber;
        }

        require(pet2TiedStatus[_mirrorTokenId].apostleTokenId == 0, "it has already been tied.");
        tokenId2PetStatus[_apostleTokenId].tiedCount += 1;
        require(tokenId2PetStatus[_apostleTokenId].tiedCount <= tokenId2PetStatus[_apostleTokenId].maxTiedNumber);

        uint256 index = tokenId2PetStatus[_apostleTokenId].tiedList.length;
        tokenId2PetStatus[_apostleTokenId].tiedList.push(_mirrorTokenId);

        pet2TiedStatus[_mirrorTokenId] = TiedStatus({
            apostleTokenId: _apostleTokenId,
            index: index
            });


        // TODO: update gene, through apostleBase
        address apostleBase = registry.addressOf(ApostleSettingIds.CONTRACT_APOSTLE_BASE);
        uint256 talents;
        uint256 genes;
        (genes,talents, , , , , , , , ) = IApostleBase(apostleBase).getApostleInfo(_apostleTokenId);
        uint256 enhancedTalents = IGeneScience(registry.addressOf(CONTRACT_GENE_SCIENCE)).enhanceWithMirrorToken(talents, _mirrorTokenId);

        bool changed = _updateTalentsAndMinerStrength(_mirrorTokenId, _apostleTokenId, genes, talents, enhancedTalents, _owner);

        emit Tied(_apostleTokenId, _mirrorTokenId, enhancedTalents, changed);

    }

    function _updateTalentsAndMinerStrength(uint256 _mirrorTokenId, uint256 _apostleTokenId, uint256 _genes, uint256 _talents, uint256 _modifiedTalents, address _owner) internal returns (bool){
        require(tokenIdIn2Out[_mirrorTokenId] != 0, "already bridged in.");
        require(ownerOfMirror(_mirrorTokenId) == _owner, "you have no right.");
        // msg.sender must own this apostle
        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);
        require(ERC721(objectOwnership).ownerOf(_apostleTokenId) == _owner, "you have no right to touch this apostle.");


        // TODO: update mine
        // changed - true
        bool changed = _talents == _modifiedTalents ? true : false;
        if(changed) {
            address landResource = registry.addressOf(CONTRACT_LAND_RESOURCE);
            if(ILandResource(landResource).landWorkingOn(_apostleTokenId) != 0) {
                // true means minus strength
                ILandResource(landResource).updateMinerStrength(_apostleTokenId, _owner, true);
            }

            IApostleBase(registry.addressOf(CONTRACT_APOSTLE_BASE)).updateGenesAndTalents(_apostleTokenId, _genes, _modifiedTalents);

            if(ILandResource(landResource).landWorkingOn(_apostleTokenId) != 0) {
                ILandResource(landResource).updateMinerStrength(_apostleTokenId, _owner, false);
            }
        }

        return changed;
    }

    function untieMirrorToken(uint256 _mirrorTokenId) public {
        uint256 apostleTokenId = pet2TiedStatus[_mirrorTokenId].apostleTokenId;
        require(apostleTokenId !=  0, "no need to untie.");

        uint256 index = pet2TiedStatus[_mirrorTokenId].index;
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

        delete pet2TiedStatus[_mirrorTokenId];


        address apostleBase = registry.addressOf(ApostleSettingIds.CONTRACT_APOSTLE_BASE);
        uint256 talents;
        uint256 genes;
        (genes,talents, , , , , , , , ) = IApostleBase(apostleBase).getApostleInfo(apostleTokenId);
        uint256 weakenTalents = IGeneScience(registry.addressOf(CONTRACT_GENE_SCIENCE)).removeMirrorToken(talents, _mirrorTokenId);


        bool changed = _updateTalentsAndMinerStrength(_mirrorTokenId, apostleTokenId, genes, talents, weakenTalents, msg.sender);

        emit UnTied(apostleTokenId, _mirrorTokenId, weakenTalents, changed);

    }




}
