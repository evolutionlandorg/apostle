pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";
import "@evolutionland/common/contracts/interfaces/ITokenUse.sol";
import "@evolutionland/common/contracts/interfaces/IMinerObject.sol";
import "@evolutionland/common/contracts/interfaces/IActivityObject.sol";
import "@evolutionland/common/contracts/interfaces/IActivity.sol";
import "@evolutionland/common/contracts/PausableDSAuth.sol";
import "openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";
import "./ApostleSettingIds.sol";
import "./interfaces/IGeneScienceV9.sol";
import "./interfaces/IHabergPotionShop.sol";
import "./interfaces/ILandBase.sol";
import "./interfaces/IRevenuePool.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IInterstellarEncoder.sol";
import "./interfaces/IItemBase.sol";
import "./interfaces/ICraftBase.sol";

// all Ids in this contracts refer to index which is using 128-bit unsigned integers.
// this is CONTRACT_APOSTLE_BASE
// V4: giveBirth must use resource
// V5: add classes
contract ApostleBaseV5 is SupportsInterfaceWithLookup, IActivity, IActivityObject, IMinerObject, PausableDSAuth, ApostleSettingIds {

    event Birth(
        address indexed owner, uint256 apostleTokenId, uint256 matronId, uint256 sireId, uint256 genes, uint256 talents, uint256 coolDownIndex, uint256 generation, uint256 birthTime
    );
    event Pregnant(
        uint256 matronId,uint256 matronCoolDownEndTime, uint256 matronCoolDownIndex, uint256 sireId, uint256 sireCoolDownEndTime, uint256 sireCoolDownIndex
    );
    //V5 add
    event ClassChange(uint256 tokenId, uint256 class);

    /// @dev The AutoBirth event is fired when a cat becomes pregant via the breedWithAuto()
    ///  function. This is used to notify the auto-birth daemon that this breeding action
    ///  included a pre-payment of the gas required to call the giveBirth() function.
    event AutoBirth(uint256 matronId, uint256 cooldownEndTime);

    event Unbox(uint256 tokenId, uint256 activeTime);

    // V5 add
    event Equip(uint256 indexed _apo_id, uint256 _slot, address _equip_token, uint256 _equip_id);
    event Divest(uint256 indexed _apo_id, uint256 _slot, address _equip_token, uint256 _equip_id);

    struct Apostle {
        // An apostles genes never change.
        uint256 genes;

        uint256 talents;

        // the ID of the parents of this Apostle. set to 0 for gen0 apostle.
        // Note that using 128-bit unsigned integers to represent parents IDs,
        // which refer to lastApostleObjectId for those two.
        uint256 matronId;
        uint256 sireId;

        // Set to the ID of the sire apostle for matrons that are pregnant,
        // zero otherwise. A non-zero value here is how we know an apostle
        // is pregnant. Used to retrieve the genetic material for the new
        // apostle when the birth transpires.
        uint256 siringWithId;
        // Set to the index in the cooldown array (see below) that represents
        // the current cooldown duration for this apostle.
        uint16 cooldownIndex;
        // The "generation number" of this apostle.
        uint16 generation;

        uint48 birthTime;
        uint48 activeTime;
        uint48 deadTime;
        uint48 cooldownEndTime;

        //v5 add
        uint256 class;
        uint256 preferExtra;
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

    modifier isHuman() {
        require(msg.sender == tx.origin, "robot is not permitted");
        _;
    }


    /*** STORAGE ***/
    bool private singletonLock = false;

    uint128 public lastApostleObjectId;

    ISettingsRegistry public registry;

    mapping(uint256 => Apostle) public tokenId2Apostle;

    mapping(uint256 => address) public sireAllowedToAddress;

    // apostle bar
    struct Bar {
        address token;
        uint256 id;
    }

    // bar status
    struct Status {
        uint256 tokenId;
        uint256 index;
    }

    // V5 add
    // apoTokenId => (apoBarIndex => Bar)
    mapping(uint256 => mapping(uint256 => Bar)) public bars;
    // equipmentTokenAddress => equipmentId => status
    mapping(address => mapping(uint256 => Status)) public statuses;

    function initializeContract(address _registry) public singletonLockCall {
        // Ownable constructor
        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        registry = ISettingsRegistry(_registry);

        _registerInterface(InterfaceId_IActivity);
        _registerInterface(InterfaceId_IActivityObject);
        _registerInterface(InterfaceId_IMinerObject);
        _updateCoolDown();

    }

    // called by gen0Apostle
    function createApostle(
        uint256 _matronId, uint256 _sireId, uint256 _generation, uint256 _genes, uint256 _talents, address _owner) public auth returns (uint256) {
        _createApostle(_matronId, _sireId, _generation, _genes, _talents, _owner);
    }

    function _createApostle(
        uint256 _matronId, uint256 _sireId, uint256 _generation, uint256 _genes, uint256 _talents, address _owner) internal returns (uint256) {

        require(_generation <= 65535);
        uint256 coolDownIndex = _generation / 2;
        if (coolDownIndex > 13) {
            coolDownIndex = 13;
        }

        Apostle memory apostle = Apostle({
            genes : _genes,
            talents : _talents,
            birthTime : uint48(now),
            activeTime : 0,
            deadTime : 0,
            cooldownEndTime : 0,
            matronId : _matronId,
            sireId : _sireId,
            siringWithId : 0,
            cooldownIndex : uint16(coolDownIndex),
            generation : uint16(_generation),
            class: 0,
            preferExtra: 0
            });

        lastApostleObjectId += 1;
        require(lastApostleObjectId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");
        uint256 tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(_owner, uint128(lastApostleObjectId));

        tokenId2Apostle[tokenId] = apostle;

        emit Birth(_owner, tokenId, apostle.matronId, apostle.sireId, _genes, _talents, uint256(coolDownIndex), uint256(_generation), now);

        return tokenId;
    }

    function getCooldownDuration(uint256 _tokenId) public view returns (uint256){
        uint256 cooldownIndex = tokenId2Apostle[_tokenId].cooldownIndex;
        return cooldowns[cooldownIndex];
    }

    // @dev Checks to see if a apostle is able to breed.
    // @param _apostleId - index of apostles which is within uint128.
    function isReadyToBreed(uint256 _apostleId)
    public
    view
    returns (bool)
    {
        require(tokenId2Apostle[_apostleId].birthTime > 0, "Apostle should exist");

        require(ITokenUse(registry.addressOf(CONTRACT_TOKEN_USE)).isObjectReadyToUse(_apostleId), "Object ready to do activity");

        // In addition to checking the cooldownEndTime, we also need to check to see if
        // the cat has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (tokenId2Apostle[_apostleId].siringWithId == 0) && (tokenId2Apostle[_apostleId].cooldownEndTime <= now);
    }

    function approveSiring(address _addr, uint256 _sireId)
    public
    whenNotPaused
    {
        ERC721 objectOwnership = ERC721(registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP));
        require(objectOwnership.ownerOf(_sireId) == msg.sender);

        sireAllowedToAddress[_sireId] = _addr;
    }

    // check apostle's owner or siring permission
    function _isSiringPermitted(uint256 _sireId, uint256 _matronId) internal view returns (bool) {
        ERC721 objectOwnership = ERC721(registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP));
        address matronOwner = objectOwnership.ownerOf(_matronId);
        address sireOwner = objectOwnership.ownerOf(_sireId);

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (matronOwner == sireOwner || sireAllowedToAddress[_sireId] == matronOwner);
    }

    function _triggerCooldown(uint256 _tokenId) internal returns (uint256) {

        Apostle storage aps = tokenId2Apostle[_tokenId];
        // Compute the end of the cooldown time (based on current cooldownIndex)
        aps.cooldownEndTime = uint48(now + uint256(cooldowns[aps.cooldownIndex]));

        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (aps.cooldownIndex < 13) {
            aps.cooldownIndex += 1;
        }

        // address(0) meaning use by its owner or whitelisted contract
        ITokenUse(registry.addressOf(SettingIds.CONTRACT_TOKEN_USE)).addActivity(_tokenId, address(0), aps.cooldownEndTime);

        return uint256(aps.cooldownEndTime);

    }

    function _isReadyToGiveBirth(Apostle storage _matron) private view returns (bool) {
        return (_matron.siringWithId != 0) && (_matron.cooldownEndTime <= now);
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _matron A reference to the apostle struct of the potential matron.
    /// @param _matronId The matron's ID.
    /// @param _sire A reference to the apostle struct of the potential sire.
    /// @param _sireId The sire's ID
    function _isValidMatingPair(
        Apostle storage _matron,
        uint256 _matronId,
        Apostle storage _sire,
        uint256 _sireId
    )
    private
    view
    returns (bool)
    {
        // An apostle can't breed with itself!
        if (_matronId == _sireId) {
            return false;
        }

        // Apostles can't breed with their parents.
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

        // Apostles can't breed with full or half siblings.
        if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId) {
            return false;
        }
        if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }


    function canBreedWith(uint256 _matronId, uint256 _sireId)
    public
    view
    returns (bool)
    {
        require(_matronId > 0);
        require(_sireId > 0);
        Apostle storage matron = tokenId2Apostle[_matronId];
        Apostle storage sire = tokenId2Apostle[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId) &&
        _isSiringPermitted(_sireId, _matronId) &&
        IGeneScienceV9(registry.addressOf(CONTRACT_GENE_SCIENCE)).isOkWithRaceAndGender(matron.genes, sire.genes);
    }


    // only can be called by SiringClockAuction
    function breedWithInAuction(uint256 _matronId, uint256 _sireId) public auth returns (bool) {

        _breedWith(_matronId, _sireId);

        Apostle storage matron = tokenId2Apostle[_matronId];
        emit AutoBirth(_matronId, matron.cooldownEndTime);
        return true;
    }


    function _breedWith(uint256 _matronId, uint256 _sireId) internal {
        require(canBreedWith(_matronId, _sireId));

        require(isReadyToBreed(_matronId));
        require(isReadyToBreed(_sireId));

        // Grab a reference to the Apostles from storage.
        Apostle storage sire = tokenId2Apostle[_sireId];

        Apostle storage matron = tokenId2Apostle[_matronId];

        // Mark the matron as pregnant, keeping track of who the sire is.
        matron.siringWithId = _sireId;

        // Trigger the cooldown for both parents.
        uint sireCoolDownEndTime = _triggerCooldown(_sireId);
        uint matronCoolDownEndTime = _triggerCooldown(_matronId);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete sireAllowedToAddress[_matronId];
        delete sireAllowedToAddress[_sireId];


        // Emit the pregnancy event.
        emit Pregnant(
            _matronId, matronCoolDownEndTime, uint256(matron.cooldownIndex), _sireId, sireCoolDownEndTime, uint256(sire.cooldownIndex));
    }


    function breedWithAuto(uint256 _matronId, uint256 _sireId, uint256 _amountMax)
    public
    whenNotPaused
    {
        // Check for payment
        // caller must approve first.
        uint256 autoBirthFee = registry.uintOf(ApostleSettingIds.UINT_AUTOBIRTH_FEE);
        require(_amountMax >= autoBirthFee, 'not enough to breed.');
        IERC20 ring = IERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN));
        require(ring.transferFrom(msg.sender, address(this), autoBirthFee), "transfer failed");

        address pool = registry.addressOf(CONTRACT_REVENUE_POOL);
        ring.approve(pool, autoBirthFee);
        IRevenuePool(pool).reward(ring, autoBirthFee, msg.sender);

        // Call through the normal breeding flow
        _breedWith(_matronId, _sireId);

        // Emit an AutoBirth message so the autobirth daemon knows when and for what cat to call
        // giveBirth().
        Apostle storage matron = tokenId2Apostle[_matronId];
        emit AutoBirth(_matronId, uint48(matron.cooldownEndTime));
    }
    /// @notice Have a pregnant apostle give birth!
    /// @param _matronId An apostle ready to give birth.
    /// @return The apostle tokenId of the new Apostles.
    /// @dev Looks at a given apostle and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new Apostles. The new apostle is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the
    ///  new Apostles will be ready to breed again. Note that anyone can call this function (if they
    ///  are willing to pay the gas!), but the new Apostles always goes to the mother's owner.
    function giveBirth(uint256 _matronId, address _resourceToken, uint256 _level, uint256 _amountMax)
    public
    isHuman
    whenNotPaused
    {

        Apostle storage matron = tokenId2Apostle[_matronId];
        uint256 sireId = matron.siringWithId;
        require(isValidResourceToken(_resourceToken), 'invalid resource token.');
        // users must approve enough resourceToken to this contract
        uint256 expense = _level * registry.uintOf(UINT_MIX_TALENT);
        require(_level > 0 && _amountMax >= expense, 'resource for mixing is not enough.');
        IERC20(_resourceToken).transferFrom(msg.sender, address(this), expense);
        require(_payAndMix(_matronId, sireId, _resourceToken, _level));

    }


    function _payAndMix(
        uint256 _matronId,
        uint256 _sireId,
        address _resourceToken,
        uint256 _level)
    internal returns (bool) {
        // Grab a reference to the matron in storage.
        Apostle storage matron = tokenId2Apostle[_matronId];
        Apostle storage sire = tokenId2Apostle[_sireId];

        // Check that the matron is a valid apostle.
        require(matron.birthTime > 0);
        require(sire.birthTime > 0);

        // Check that the matron is pregnant, and that its time has come!
        require(_isReadyToGiveBirth(matron));

        // Grab a reference to the sire in storage.
        //        uint256 sireId = matron.siringWithId;
        // prevent stack too deep error
        //        Apostle storage sire = tokenId2Apostle[matron.siringWithId];

        // Determine the higher generation number of the two parents
        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }

        // Call the sooper-sekret, sooper-expensive, gene mixing operation.
        (uint256 childGenes, uint256 childTalents) = IGeneScienceV9(registry.addressOf(CONTRACT_GENE_SCIENCE)).mixGenesAndTalents(matron.genes, sire.genes, matron.talents, sire.talents, _resourceToken, _level);

        address owner = ERC721(registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_matronId);
        // Make the new Apostle!
        _createApostle(_matronId, matron.siringWithId, parentGen + 1, childGenes, childTalents, owner);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete matron.siringWithId;

        return true;
    }

    function isValidResourceToken(address _resourceToken) public view returns (bool) {
        uint index = ILandBase(registry.addressOf(SettingIds.CONTRACT_LAND_BASE)).resourceToken2RateAttrId(_resourceToken);
        return index > 0;
    }


    /// Anyone can try to kill this Apostle;
    function killApostle(uint256 _tokenId) public {
        require(tokenId2Apostle[_tokenId].activeTime > 0);
        require(defaultLifeTime(_tokenId) < now);

        address habergPotionShop = registry.addressOf(CONTRACT_HABERG_POTION_SHOP);
        IHabergPotionShop(habergPotionShop).tryKillApostle(_tokenId, msg.sender);
    }

    function isDead(uint256 _tokenId) public view returns (bool) {
        return tokenId2Apostle[_tokenId].birthTime > 0 && tokenId2Apostle[_tokenId].deadTime > 0;
    }

    function defaultLifeTime(uint256 _tokenId) public view returns (uint256) {
        uint256 start = tokenId2Apostle[_tokenId].birthTime;

        if (tokenId2Apostle[_tokenId].activeTime > 0) {
            start = tokenId2Apostle[_tokenId].activeTime;
        }

        return start + (tokenId2Apostle[_tokenId].talents >> 248) * (1 weeks);
    }

    /// IMinerObject
    function strengthOf(uint256 _tokenId, address _resourceToken, uint256 _landTokenId) public view returns (uint256) {
        Apostle memory apo = tokenId2Apostle[_tokenId];
        return IGeneScienceV9(registry.addressOf(CONTRACT_GENE_SCIENCE))
        .getStrength(apo.talents, _resourceToken, _landTokenId, apo.preferExtra, getClassEnhance(apo.class));
    }

    /// IActivityObject
    function activityAdded(uint256 _tokenId, address /*_activity*/, address /*_user*/) auth public {
        // to active the apostle when it do activity the first time
        if (tokenId2Apostle[_tokenId].activeTime == 0) {
            tokenId2Apostle[_tokenId].activeTime = uint48(now);

            emit Unbox(_tokenId, now);
        }

    }

    function activityRemoved(uint256 /*_tokenId*/, address /*_activity*/, address /*_user*/) auth public {
        // do nothing.
    }

    /// IActivity
    function activityStopped(uint256 /*_tokenId*/) auth public {
        // do nothing.
    }

    function getApostleInfo(uint256 _tokenId) public view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256) {
        Apostle storage apostle = tokenId2Apostle[_tokenId];
        return (
        apostle.genes,
        apostle.talents,
        apostle.matronId,
        apostle.sireId,
        uint256(apostle.cooldownIndex),
        uint256(apostle.generation),
        uint256(apostle.birthTime),
        uint256(apostle.activeTime),
        uint256(apostle.deadTime),
        uint256(apostle.cooldownEndTime)
        );
    }

    function _updateCoolDown() internal {
        cooldowns[0] =  uint32(1 minutes);
        cooldowns[1] =  uint32(2 minutes);
        cooldowns[2] =  uint32(5 minutes);
        cooldowns[3] =  uint32(10 minutes);
        cooldowns[4] =  uint32(30 minutes);
        cooldowns[5] =  uint32(1 hours);
        cooldowns[6] =  uint32(2 hours);
        cooldowns[7] =  uint32(4 hours);
        cooldowns[8] =  uint32(8 hours);
        cooldowns[9] =  uint32(16 hours);
        cooldowns[10] =  uint32(1 days);
        cooldowns[11] =  uint32(2 days);
        cooldowns[12] =  uint32(4 days);
        cooldowns[13] =  uint32(7 days);
    }

    function updateGenesAndTalents(uint256 _tokenId, uint256 _genes, uint256 _talents) public auth {
        Apostle storage aps = tokenId2Apostle[_tokenId];
        aps.genes = _genes;
        aps.talents = _talents;
    }

    function batchUpdate(uint256[] _tokenIds, uint256[] _genesList, uint256[] _talentsList) public auth {
        require(_tokenIds.length == _genesList.length && _tokenIds.length == _talentsList.length);
        for(uint i = 0; i < _tokenIds.length; i++) {
            Apostle storage aps = tokenId2Apostle[_tokenIds[i]];
            aps.genes = _genesList[i];
            aps.talents = _talentsList[i];
        }

    }

    //v5 add
    function classes(uint256 id) external pure returns (string memory desc) {
        if (id == 0) {
            return "None";
        } else if (id == 1) {
            return "Saber";
        } else if (id == 2) {
            return "Guard";
        } else if (id == 3) {
            return "Miner";
        }
    }

    function getClassEnhance(uint256 id) public pure returns (uint256 enhance) {
        if (id == 3) {
            enhance = 3;
        }
    }

    function changeClass(uint256 tokenId, uint256 _class, uint256 _amountMax) external {
        require(1 <= _class && _class <= 2, "!class");
        require(ITokenUse(registry.addressOf(CONTRACT_TOKEN_USE)).isObjectReadyToUse(tokenId), "!use");
		require(msg.sender == ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(tokenId), "!owner");

        // require(equipment is null)
        Apostle storage apo = tokenId2Apostle[tokenId];
        require(apo.class != _class, '!class');

        uint256 changeClassFee = registry.uintOf(UINT_CHANGECLASS_FEE);
        require(_amountMax >= changeClassFee, '!enough');
        IERC20 ring = IERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN));
        require(ring.transferFrom(msg.sender, address(this), changeClassFee), '!transfer');

        address pool = registry.addressOf(CONTRACT_REVENUE_POOL);
        ring.approve(pool, changeClassFee);
        IRevenuePool(pool).reward(ring, changeClassFee, msg.sender);

        apo.class = _class;
        emit ClassChange(tokenId, apo.class);
    }

    function get_equip_bar_name(uint256 slot) external pure returns (string memory desc) {
        if (slot == 1) {
            desc = "Right Hand Bar";
        }
    }

    function _equip_check(uint256 _apo_id, uint256 _slot, address _equip_token) private view {
        address ownership = registry.addressOf(CONTRACT_OBJECT_OWNERSHIP);
		require(msg.sender == ERC721(ownership).ownerOf(_apo_id), "!owner");
        require(_slot == 1, "!slot");
        require(bars[_apo_id][_slot].token == address(0), "exist");
        require(_equip_token == ownership, "!token");
        require(ITokenUse(registry.addressOf(CONTRACT_TOKEN_USE)).isObjectReadyToUse(_apo_id), "!use");
    }

    function equip(uint256 _apo_id, uint256 _slot, address _equip_token, uint256 _equip_id) external whenNotPaused {
        _equip_check(_apo_id, _slot, _equip_token);
        address encoder = registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER);
        require(IInterstellarEncoder(encoder).getObjectClass(_equip_id) == EQUIPMENT_OBJECT_CLASS, "!eclass");
        address objectAddress = IInterstellarEncoder(encoder).getObjectAddress(_equip_id);
        (uint256 obj_id,,uint256 class, uint256 prefer) = ICraftBase(objectAddress).getMetaData(_equip_id);
        require(tokenId2Apostle[_apo_id].class == obj_id, "!aclass");
        _update_extra_prefer(_apo_id, prefer, class, true);
        ERC721(_equip_token).transferFrom(msg.sender, address(this), _equip_id);
        bars[_apo_id][_slot] = Bar(_equip_token, _equip_id);
        statuses[_equip_token][_equip_id] = Status(_apo_id, _slot);
        emit Equip(_apo_id, _slot, _equip_token, _equip_id);
    }

    function _update_extra_prefer(uint256 _apo_id, uint256 prefer, uint256 class, bool flag) internal {
        uint256 preferExtra = tokenId2Apostle[_apo_id].preferExtra;
        preferExtra = _calc_extra_prefer(prefer, preferExtra, class, flag);
        tokenId2Apostle[_apo_id].preferExtra = preferExtra;
    }

    function _calc_extra_prefer(uint256 prefer, uint256 preferExtra, uint256 class, bool flag) internal pure returns (uint256 newPreferExtra) {
        for (uint256 i = 1; i < 6; i++) {
            if (prefer & (1 << i) > 0) {
                if (flag) {
                    newPreferExtra = preferExtra + ((class + 1) << ((i-1) * 16));
                } else {
                    newPreferExtra = preferExtra - ((class + 1) << ((i-1) * 16));
                }
            }
        }
    }

    function divest(uint256 _apo_id, uint256 _slot) external whenNotPaused {
        Bar memory bar = bars[_apo_id][_slot];
        require(bar.token != address(0), "!exist");
		require(msg.sender == ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_apo_id), "!owner");
        require(ITokenUse(registry.addressOf(CONTRACT_TOKEN_USE)).isObjectReadyToUse(_apo_id), "!use");
        address objectAddress = IInterstellarEncoder(registry.addressOf(CONTRACT_INTERSTELLAR_ENCODER)).getObjectAddress(bar.id);
        (uint256 obj_id,,uint256 class, uint256 prefer) = ICraftBase(objectAddress).getMetaData(bar.id);
        _update_extra_prefer(_apo_id, prefer, class, false);
        ERC721(bar.token).transferFrom(address(this), msg.sender, bar.id);
        delete statuses[bar.token][bar.id];
        delete bars[_apo_id][_slot];
        emit Divest(_apo_id, _slot, bar.token, bar.id);
    }
}


