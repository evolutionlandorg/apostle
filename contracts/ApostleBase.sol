pragma solidity ^0.4.24;

import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/PausableDSAuth.sol";
import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";
import "./ApostleSettingIds.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "./interfaces/GeneScienceInterface.sol";

// all Ids in this contracts refer to index which is using 128-bit unsigned integers.
contract ApostleBase is PausableDSAuth, ApostleSettingIds {

    event Birth(address indexed owner, uint128 apostleId, uint128 matronId, uint128 sireId, uint256 genes, uint256 talents);
    event Pregnant(address owner, uint128 matronId, uint128 sireId);

    /// @dev The AutoBirth event is fired when a cat becomes pregant via the breedWithAuto()
    ///  function. This is used to notify the auto-birth daemon that this breeding action
    ///  included a pre-payment of the gas required to call the giveBirth() function.
    event AutoBirth(uint128 matronId, uint256 cooldownEndTime);

    struct Apostle {
        // An apostles genes never change.
        uint256 genes;

        uint256 talents;

        // the ID of the parents of this Apostle. set to 0 for gen0 apostle.
        // Note that using 128-bit unsigned integers to represent parents IDs,
        // which refer to lastApostleObjectId for those two.
        uint128 matronId;
        uint128 sireId;

        // Set to the ID of the sire apostle for matrons that are pregnant,
        // zero otherwise. A non-zero value here is how we know an apostle
        // is pregnant. Used to retrieve the genetic material for the new
        // apostle when the birth transpires.
        uint128 siringWithId;
        // Set to the index in the cooldown array (see below) that represents
        // the current cooldown duration for this apostle.
        uint16 cooldownIndex;
        // The "generation number" of this apostle.
        uint16 generation;

        uint48 birthTime;
        uint48 cooldownEndTime;
    }

    uint32[14] public cooldowns = [
    uint32(1 minutes),
    uint32(2 minutes),
    uint32(5 minutes),
    uint32(10 minutes),
    uint32(30 minutes),
    uint32(1 hours),
    uint32(2 hours),
    uint32(4 hours),
    uint32(8 hours),
    uint32(16 hours),
    uint32(1 days),
    uint32(2 days),
    uint32(4 days),
    uint32(7 days)
    ];


    /*
     *  Modifiers
     */
    modifier singletonLockCall() {
        require(!singletonLock, "Only can call once");
        _;
        singletonLock = true;
    }


    /*** STORAGE ***/
    bool private singletonLock = false;

    uint128 public lastApostleObjectId;

    ISettingsRegistry registry;

    /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
    ///  the gas cost paid by the auto-birth daemon, and can be dynamically updated by
    ///  the COO role as the gas price changes.
    uint256 public autoBirthFee = 1000000 * 1000000000; // (1M * 1 gwei)

    mapping(uint256 => Apostle) public tokenId2Apostle;

    mapping(uint128 => uint256) public index2TokenId;

    mapping(uint128 => address) public sireAllowedToAddress;


    /// @dev The address of the sibling contract that is used to implement the sooper-sekret
    ///  genetic combination algorithm.
    // TODO: put this into registry
    GeneScienceInterface public geneScience;


    function initializeContract(address _registry) public singletonLockCall {
        // Ownable constructor
        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        registry = ISettingsRegistry(_registry);
    }

    function _createApostle(uint128 _matronId, uint128 _sireId, uint256 _generation, uint256 _genes, uint256 _talents, address _owner) internal returns (uint128) {

        require(_generation <= 65535);

        Apostle memory apostle = Apostle({
            genes : _genes,
            talents : _talents,
            birthTime : uint48(now),
            cooldownEndTime : 0,
            matronId : _matronId,
            sireId : _sireId,
            siringWithId : 0,
            cooldownIndex : 0,
            generation : uint16(_generation)
            });

        lastApostleObjectId += 1;
        require(lastApostleObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");
        uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(_owner, uint128(lastApostleObjectId));

        tokenId2Apostle[tokenId] = apostle;
        index2TokenId[lastApostleObjectId] = tokenId;

        emit Birth(_owner, lastApostleObjectId, apostle.matronId, apostle.sireId, apostle.genes, _talents);

        return lastApostleObjectId;
    }

    function _isReadyToBreed(Apostle storage _aps) internal view returns (bool) {
        // In addition to checking the cooldownEndTime, we also need to check to see if
        // the cat has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (_aps.siringWithId == 0) && (_aps.cooldownEndTime <= now);
    }

    // @dev Checks to see if a apostle is able to breed.
    // @param _apostleId - index of apostles which is within uint128.
    function isReadyToBreed(uint128 _apostleId)
    public
    view
    returns (bool)
    {
        require(_apostleId > 0);
        Apostle storage aps = tokenId2Apostle[index2TokenId[_apostleId]];
        return _isReadyToBreed(aps);
    }

    function approveSiring(address _addr, uint128 _sireId)
    public
    whenNotPaused
    {
        ERC721 objectOwnership = ERC721(registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP));
        uint tokenId = index2TokenId[_sireId];
        require(objectOwnership.ownerOf(tokenId) == msg.sender);
        sireAllowedToAddress[_sireId] = _addr;
    }

    function _isSiringPermitted(uint128 _sireId, uint128 _matronId) internal view returns (bool) {
        ERC721 objectOwnership = ERC721(registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP));
        address matronOwner = objectOwnership.ownerOf(index2TokenId[_matronId]);
        address sireOwner = objectOwnership.ownerOf(index2TokenId[_sireId]);

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (matronOwner == sireOwner || sireAllowedToAddress[_sireId] == matronOwner);
    }

    function _triggerCooldown(Apostle storage _aps) internal {
        // Compute the end of the cooldown time (based on current cooldownIndex)
        _aps.cooldownEndTime = uint48(now + uint256(cooldowns[_aps.cooldownIndex]));

        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_aps.cooldownIndex < 13) {
            _aps.cooldownIndex += 1;
        }
    }

    function setAutoBirthFee(uint256 _val) public onlyOwner {
        autoBirthFee = _val;
    }

    function _isReadyToGiveBirth(Apostle storage _matron) private view returns (bool) {
        return (_matron.siringWithId != 0) && (_matron.cooldownEndTime <= now);
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _matron A reference to the Kitty struct of the potential matron.
    /// @param _matronId The matron's ID.
    /// @param _sire A reference to the Kitty struct of the potential sire.
    /// @param _sireId The sire's ID
    function _isValidMatingPair(
        Apostle storage _matron,
        uint128 _matronId,
        Apostle storage _sire,
        uint128 _sireId
    )
    private
    view
    returns (bool)
    {
        // A Kitty can't breed with itself!
        if (_matronId == _sireId) {
            return false;
        }

        // Kitties can't breed with their parents.
        if (_matron.matronId == _sireId || _matron.sireId == _sireId) {
            return false;
        }
        if (_sire.matronId == _matronId || _sire.sireId == _matronId) {
            return false;
        }

        // We can short circuit the sibling check (below) if either cat is
        // gen zero (has a matron ID of zero).
        if (_sire.matronId == 0 || _matron.matronId == 0) {
            return true;
        }

        // Kitties can't breed with full or half siblings.
        if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId) {
            return false;
        }
        if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    function _canBreedWithViaAuction(uint128 _matronId, uint128 _sireId)
    internal
    view
    returns (bool)
    {
        Apostle storage matron = tokenId2Apostle[index2TokenId[_matronId]];
        Apostle storage sire = tokenId2Apostle[index2TokenId[_sireId]];
        return _isValidMatingPair(matron, _matronId, sire, _sireId);
    }

    function canBreedWith(uint128 _matronId, uint128 _sireId)
    public
    view
    returns (bool)
    {
        require(_matronId > 0);
        require(_sireId > 0);
        Apostle storage matron = tokenId2Apostle[index2TokenId[_matronId]];
        Apostle storage sire = tokenId2Apostle[index2TokenId[_sireId]];
        return _isValidMatingPair(matron, _matronId, sire, _sireId) &&
        _isSiringPermitted(_sireId, _matronId);
    }


    function breedWith(uint128 _matronId, uint128 _sireId) public whenNotPaused {
        // Caller must own the matron.
        ERC721 objectOwnership = ERC721(registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP));
        uint tokenId = index2TokenId[_matronId];
        require(objectOwnership.ownerOf(tokenId) == msg.sender);

        // Neither sire nor matron are allowed to be on auction during a normal
        // breeding operation, but we don't need to check that explicitly.
        // For matron: The caller of this function can't be the owner of the matron
        //   because the owner of a Kitty on auction is the auction house, and the
        //   auction house will never call breedWith().
        // For sire: Similarly, a sire on auction will be owned by the auction house
        //   and the act of transferring ownership will have cleared any oustanding
        //   siring approval.
        // Thus we don't need to spend gas explicitly checking to see if either cat
        // is on auction.

        // Check that matron and sire are both owned by caller, or that the sire
        // has given siring permission to caller (i.e. matron's owner).
        // Will fail for _sireId = 0
        require(_isSiringPermitted(_sireId, _matronId));

        // Grab a reference to the potential matron
        Apostle storage matron = tokenId2Apostle[index2TokenId[_matronId]];

        // Make sure matron isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToBreed(matron));

        // Grab a reference to the potential sire
        Apostle storage sire = tokenId2Apostle[index2TokenId[_sireId]];

        // Make sure sire isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToBreed(sire));

        // Test that these cats are a valid mating pair.
        require(_isValidMatingPair(
                matron,
                _matronId,
                sire,
                _sireId
            ));

        // All checks passed, kitty gets pregnant!
        _breedWith(objectOwnership, _matronId, _sireId);
    }

    function _breedWith(ERC721 _objectOwnership, uint128 _matronId, uint128 _sireId) internal {
        // Grab a reference to the Kitties from storage.
        Apostle storage sire = tokenId2Apostle[index2TokenId[_sireId]];

        Apostle storage matron = tokenId2Apostle[index2TokenId[_matronId]];

        // Mark the matron as pregnant, keeping track of who the sire is.
        matron.siringWithId = _sireId;

        // Trigger the cooldown for both parents.
        _triggerCooldown(sire);
        _triggerCooldown(matron);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete sireAllowedToAddress[_matronId];
        delete sireAllowedToAddress[_sireId];

        uint matronTokenId = index2TokenId[_matronId];
        address matronOwner = _objectOwnership.ownerOf(matronTokenId);

        // Emit the pregnancy event.
        emit Pregnant(matronOwner, _matronId, _sireId);
    }

    function breedWithAuto(uint128 _matronId, uint128 _sireId)
    public
    payable
    whenNotPaused
    {
        // Check for payment
        require(msg.value >= autoBirthFee);

        // Call through the normal breeding flow
        breedWith(_matronId, _sireId);

        // Emit an AutoBirth message so the autobirth daemon knows when and for what cat to call
        // giveBirth().
        Apostle storage matron = tokenId2Apostle[index2TokenId[_matronId]];
        emit AutoBirth(_matronId, uint48(matron.cooldownEndTime));
    }

    /// @notice Have a pregnant Kitty give birth!
    /// @param _matronId A Kitty ready to give birth.
    /// @return The Kitty ID of the new kitten.
    /// @dev Looks at a given Kitty and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new kitten. The new Kitty is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the
    ///  new kitten will be ready to breed again. Note that anyone can call this function (if they
    ///  are willing to pay the gas!), but the new kitten always goes to the mother's owner.
    function giveBirth(uint128 _matronId)
    public
    whenNotPaused
    returns (uint128)
    {
        // Grab a reference to the matron in storage.
        Apostle storage matron = tokenId2Apostle[index2TokenId[_matronId]];

        // Check that the matron is a valid cat.
        require(matron.birthTime != 0);

        // Check that the matron is pregnant, and that its time has come!
        require(_isReadyToGiveBirth(matron));

        // Grab a reference to the sire in storage.
        uint128 sireId = matron.siringWithId;
        Apostle storage sire = tokenId2Apostle[index2TokenId[sireId]];

        // Determine the higher generation number of the two parents
        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }

        // Call the sooper-sekret, sooper-expensive, gene mixing operation.
        uint256 childGenes = geneScience.mixGenes(matron.genes, sire.genes);
        uint256 childTalents = geneScience.mixTalents(matron.talents, sire.talents);

        ERC721 objectOwnership = ERC721(registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP));
        uint tokenId = index2TokenId[_matronId];
        address owner = objectOwnership.ownerOf(tokenId);
        // Make the new kitten!
        uint128 apostleId = _createApostle(_matronId, matron.siringWithId, parentGen + 1, childGenes, childTalents, owner);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete matron.siringWithId;

        // return the new kitten's ID
        return apostleId;
    }


}


