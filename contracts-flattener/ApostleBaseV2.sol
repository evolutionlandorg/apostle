// Dependency file: openzeppelin-solidity/contracts/introspection/ERC165.sol

// pragma solidity ^0.4.24;


/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}


// Dependency file: openzeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol

// pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/introspection/ERC165.sol";


/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic is ERC165 {

  bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;
  /*
   * 0x80ac58cd ===
   *   bytes4(keccak256('balanceOf(address)')) ^
   *   bytes4(keccak256('ownerOf(uint256)')) ^
   *   bytes4(keccak256('approve(address,uint256)')) ^
   *   bytes4(keccak256('getApproved(uint256)')) ^
   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
   */

  bytes4 internal constant InterfaceId_ERC721Exists = 0x4f558e79;
  /*
   * 0x4f558e79 ===
   *   bytes4(keccak256('exists(uint256)'))
   */

  bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;
  /**
   * 0x780e9d63 ===
   *   bytes4(keccak256('totalSupply()')) ^
   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
   *   bytes4(keccak256('tokenByIndex(uint256)'))
   */

  bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;
  /**
   * 0x5b5e139f ===
   *   bytes4(keccak256('name()')) ^
   *   bytes4(keccak256('symbol()')) ^
   *   bytes4(keccak256('tokenURI(uint256)'))
   */

  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId)
    public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;
}


// Dependency file: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol

// pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol";


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256 _tokenId);

  function tokenByIndex(uint256 _index) public view returns (uint256);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}


// Dependency file: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

// pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


// Dependency file: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

// pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol";


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


// Dependency file: @evolutionland/common/contracts/interfaces/ISettingsRegistry.sol

// pragma solidity ^0.4.24;

contract ISettingsRegistry {
    enum SettingsValueTypes { NONE, UINT, STRING, ADDRESS, BYTES, BOOL, INT }

    function uintOf(bytes32 _propertyName) public view returns (uint256);

    function stringOf(bytes32 _propertyName) public view returns (string);

    function addressOf(bytes32 _propertyName) public view returns (address);

    function bytesOf(bytes32 _propertyName) public view returns (bytes);

    function boolOf(bytes32 _propertyName) public view returns (bool);

    function intOf(bytes32 _propertyName) public view returns (int);

    function setUintProperty(bytes32 _propertyName, uint _value) public;

    function setStringProperty(bytes32 _propertyName, string _value) public;

    function setAddressProperty(bytes32 _propertyName, address _value) public;

    function setBytesProperty(bytes32 _propertyName, bytes _value) public;

    function setBoolProperty(bytes32 _propertyName, bool _value) public;

    function setIntProperty(bytes32 _propertyName, int _value) public;

    function getValueTypeOf(bytes32 _propertyName) public view returns (uint /* SettingsValueTypes */ );

    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}

// Dependency file: @evolutionland/common/contracts/interfaces/IObjectOwnership.sol

// pragma solidity ^0.4.24;

contract IObjectOwnership {
    function mintObject(address _to, uint128 _objectId) public returns (uint256 _tokenId);

    function burnObject(address _to, uint128 _objectId) public returns (uint256 _tokenId);
}

// Dependency file: @evolutionland/common/contracts/interfaces/ITokenUse.sol

// pragma solidity ^0.4.24;

contract ITokenUse {
    uint48 public constant MAX_UINT48_TIME = 281474976710655;

    function isObjectInHireStage(uint256 _tokenId) public view returns (bool);

    function isObjectReadyToUse(uint256 _tokenId) public view returns (bool);

    function getTokenUser(uint256 _tokenId) public view returns (address);

    function createTokenUseOffer(uint256 _tokenId, uint256 _duration, uint256 _price, address _acceptedActivity) public;

    function cancelTokenUseOffer(uint256 _tokenId) public;

    function takeTokenUseOffer(uint256 _tokenId) public;

    function addActivity(uint256 _tokenId, address _user, uint256 _endTime) public;

    function removeActivity(uint256 _tokenId, address _user) public;
}

// Dependency file: @evolutionland/common/contracts/interfaces/IMinerObject.sol

// pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/introspection/ERC165.sol";

contract IMinerObject is ERC165  {
    bytes4 internal constant InterfaceId_IMinerObject = 0x64272b75;
    
    /*
     * 0x64272b752 ===
     *   bytes4(keccak256('strengthOf(uint256,address)'))
     */

    function strengthOf(uint256 _tokenId, address _resourceToken, uint256 _landTokenId) public view returns (uint256);

}

// Dependency file: @evolutionland/common/contracts/interfaces/IActivityObject.sol

// pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/introspection/ERC165.sol";

contract IActivityObject is ERC165 {
    bytes4 internal constant InterfaceId_IActivityObject = 0x2b9eccc6; 
    /*
     * 0x2b9eccc6 ===
     *   bytes4(keccak256('activityAdded(uint256,address,address)')) ^ 
     *   bytes4(keccak256('activityRemoved(uint256,address,address)'))
     */

    function activityAdded(uint256 _tokenId, address _activity, address _user) public;

    function activityRemoved(uint256 _tokenId, address _activity, address _user) public;
}

// Dependency file: @evolutionland/common/contracts/interfaces/IActivity.sol

// pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/introspection/ERC165.sol";

contract IActivity is ERC165 {
    bytes4 internal constant InterfaceId_IActivity = 0x6086e7f8; 
    /*
     * 0x6086e7f8 ===
     *   bytes4(keccak256('activityStopped(uint256)'))
     */

    function activityStopped(uint256 _tokenId) public;
}

// Dependency file: @evolutionland/common/contracts/interfaces/IAuthority.sol

// pragma solidity ^0.4.24;

contract IAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

// Dependency file: @evolutionland/common/contracts/DSAuth.sol

// pragma solidity ^0.4.24;

// import '/Users/echo/workspace/contract/evolutionlandorg/apostle/node_modules/@evolutionland/common/contracts/interfaces/IAuthority.sol';

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

/**
 * @title DSAuth
 * @dev The DSAuth contract is reference implement of https://github.com/dapphub/ds-auth
 * But in the isAuthorized method, the src from address(this) is remove for safty concern.
 */
contract DSAuth is DSAuthEvents {
    IAuthority   public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(IAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == owner) {
            return true;
        } else if (authority == IAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}


// Dependency file: @evolutionland/common/contracts/PausableDSAuth.sol

// pragma solidity ^0.4.24;

// import "@evolutionland/common/contracts/DSAuth.sol";


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract PausableDSAuth is DSAuth {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// Dependency file: @evolutionland/common/contracts/interfaces/ERC223.sol

// pragma solidity ^0.4.23;

contract ERC223 {
    function transfer(address to, uint amount, bytes data) public returns (bool ok);

    function transferFrom(address from, address to, uint256 amount, bytes data) public returns (bool ok);

    event ERC223Transfer(address indexed from, address indexed to, uint amount, bytes data);
}


// Dependency file: openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol

// pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/introspection/ERC165.sol";


/**
 * @title SupportsInterfaceWithLookup
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract SupportsInterfaceWithLookup is ERC165 {

  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */

  /**
   * @dev a mapping of interface id to whether or not it's supported
   */
  mapping(bytes4 => bool) internal supportedInterfaces;

  /**
   * @dev A contract implementing SupportsInterfaceWithLookup
   * implement ERC165 itself
   */
  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

  /**
   * @dev implement supportsInterface(bytes4) using a lookup table
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceId];
  }

  /**
   * @dev private method for registering an interface
   */
  function _registerInterface(bytes4 _interfaceId)
    internal
  {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}


// Dependency file: @evolutionland/common/contracts/SettingIds.sol

// pragma solidity ^0.4.24;

/**
    Id definitions for SettingsRegistry.sol
    Can be used in conjunction with the settings registry to get properties
*/
contract SettingIds {
    bytes32 public constant CONTRACT_RING_ERC20_TOKEN = "CONTRACT_RING_ERC20_TOKEN";

    bytes32 public constant CONTRACT_KTON_ERC20_TOKEN = "CONTRACT_KTON_ERC20_TOKEN";

    bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN = "CONTRACT_GOLD_ERC20_TOKEN";

    bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN = "CONTRACT_WOOD_ERC20_TOKEN";

    bytes32 public constant CONTRACT_WATER_ERC20_TOKEN = "CONTRACT_WATER_ERC20_TOKEN";

    bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN = "CONTRACT_FIRE_ERC20_TOKEN";

    bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN = "CONTRACT_SOIL_ERC20_TOKEN";

    bytes32 public constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";

    bytes32 public constant CONTRACT_TOKEN_LOCATION = "CONTRACT_TOKEN_LOCATION";

    bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

    bytes32 public constant CONTRACT_USER_POINTS = "CONTRACT_USER_POINTS";

    bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER = "CONTRACT_INTERSTELLAR_ENCODER";

    bytes32 public constant CONTRACT_DIVIDENDS_POOL = "CONTRACT_DIVIDENDS_POOL";

    bytes32 public constant CONTRACT_TOKEN_USE = "CONTRACT_TOKEN_USE";

    bytes32 public constant CONTRACT_REVENUE_POOL = "CONTRACT_REVENUE_POOL";

    bytes32 public constant CONTRACT_ERC721_BRIDGE = "CONTRACT_ERC721_BRIDGE";

    bytes32 public constant CONTRACT_PET_BASE = "CONTRACT_PET_BASE";

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // this can be considered as transaction fee.
    // Values 0-10,000 map to 0%-100%
    // set ownerCut to 4%
    // ownerCut = 400;
    bytes32 public constant UINT_AUCTION_CUT = "UINT_AUCTION_CUT";  // Denominator is 10000

    bytes32 public constant UINT_TOKEN_OFFER_CUT = "UINT_TOKEN_OFFER_CUT";  // Denominator is 10000

    // Cut referer takes on each auction, measured in basis points (1/100 of a percent).
    // which cut from transaction fee.
    // Values 0-10,000 map to 0%-100%
    // set refererCut to 4%
    // refererCut = 400;
    bytes32 public constant UINT_REFERER_CUT = "UINT_REFERER_CUT";

    bytes32 public constant CONTRACT_LAND_RESOURCE = "CONTRACT_LAND_RESOURCE";
}

// Dependency file: contracts/ApostleSettingIds.sol

// pragma solidity ^0.4.24;
// import "@evolutionland/common/contracts/SettingIds.sol";


contract ApostleSettingIds is SettingIds {

    bytes32 public constant CONTRACT_GENE_SCIENCE = "CONTRACT_GENE_SCIENCE";

    /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
    ///  the gas cost paid by the auto-birth daemon, and can be dynamically updated by
    ///  the COO role as the gas price changes.
    bytes32 public constant UINT_AUTOBIRTH_FEE = "UINT_AUTOBIRTH_FEE";

    bytes32 public constant CONTRACT_APOSTLE_BASE = "CONTRACT_APOSTLE_BASE";

    bytes32 public constant CONTRACT_SIRING_AUCTION = "CONTRACT_SIRING_AUCTION";

    bytes32 public constant CONTRACT_APOSTLE_AUCTION = "CONTRACT_APOSTLE_AUCTION";

    bytes32 public constant CONTRACT_HABERG_POTION_SHOP = "CONTRACT_HABERG_POTION_SHOP";

    // when player wants to buy their apostle some talents
    // the minimum or unit they need to pay
    bytes32 public constant UINT_MIX_TALENT = "UINT_MIX_TALENT";

    bytes32 public constant UINT_APOSTLE_BID_WAITING_TIME = "UINT_APOSTLE_BID_WAITING_TIME";

    /// Denominator is 100000000
    bytes32 public constant UINT_HABERG_POTION_TAX_RATE = "UINT_HABERG_POTION_TAX_RATE";

    // TODO: move this to common-contract
    bytes32 public constant CONTRACT_LAND_RESOURCE = "CONTRACT_LAND_RESOURCE";
}


// Dependency file: contracts/interfaces/IGeneScience.sol

// pragma solidity ^0.4.24;


/// @title defined the interface that will be referenced in main Kitty contract
contract IGeneScience {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isGeneScience() public pure returns (bool);

    /// @dev given genes of apostle 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of sire
    /// @param talents1 talents of mom
    /// @param talents2 talents of sire
    /// @return the genes and talents that are supposed to be passed down the child
    function mixGenesAndTalents(uint256 genes1, uint256 genes2, uint256 talents1, uint256 talents2, address resouceToken, uint256 level) public returns (uint256, uint256);

    function getStrength(uint256 _talents, address _resourceToken, uint256 _landTokenId) public view returns (uint256);

    function isOkWithRaceAndGender(uint _matronGenes, uint _sireGenes) public view returns (bool);

    function enhanceWithMirrorToken(uint256 _talents, uint256 _mirrorTokenId) public view returns (uint256);

    function removeMirrorToken(uint256 _addedTalents, uint256 _mirrorTokenId) public view returns (uint256);
}


// Dependency file: contracts/interfaces/IHabergPotionShop.sol

// pragma solidity ^0.4.24;

contract IHabergPotionShop {
    function tryKillApostle(uint256 _tokenId, address _killer) public;

    function harbergLifeTime(uint256 _tokenId) public view;

}

// Dependency file: contracts/interfaces/ILandBase.sol

// pragma solidity ^0.4.24;

contract ILandBase {

    function resourceToken2RateAttrId(address _resourceToken) public view returns (uint256);
}

// Root file: contracts/ApostleBaseV2.sol

pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
// import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
// import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
// import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";
// import "@evolutionland/common/contracts/interfaces/ITokenUse.sol";
// import "@evolutionland/common/contracts/interfaces/IMinerObject.sol";
// import "@evolutionland/common/contracts/interfaces/IActivityObject.sol";
// import "@evolutionland/common/contracts/interfaces/IActivity.sol";
// import "@evolutionland/common/contracts/PausableDSAuth.sol";
// import "@evolutionland/common/contracts/interfaces/ERC223.sol";
// import "openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol";
// import "contracts/ApostleSettingIds.sol";
// import "contracts/interfaces/IGeneScience.sol";
// import "contracts/interfaces/IHabergPotionShop.sol";
// import "contracts/interfaces/ILandBase.sol";

// all Ids in this contracts refer to index which is using 128-bit unsigned integers.
// this is CONTRACT_APOSTLE_BASE
contract ApostleBaseV2 is SupportsInterfaceWithLookup, IActivity, IActivityObject, IMinerObject, PausableDSAuth, ApostleSettingIds {

    event Birth(
        address indexed owner, uint256 apostleTokenId, uint256 matronId, uint256 sireId, uint256 genes, uint256 talents, uint256 coolDownIndex, uint256 generation, uint256 birthTime
    );
    event Pregnant(
        uint256 matronId,uint256 matronCoolDownEndTime, uint256 matronCoolDownIndex, uint256 sireId, uint256 sireCoolDownEndTime, uint256 sireCoolDownIndex
    );

    /// @dev The AutoBirth event is fired when a cat becomes pregant via the breedWithAuto()
    ///  function. This is used to notify the auto-birth daemon that this breeding action
    ///  included a pre-payment of the gas required to call the giveBirth() function.
    event AutoBirth(uint256 matronId, uint256 cooldownEndTime);

    event Unbox(uint256 tokenId, uint256 activeTime);

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
            generation : uint16(_generation)
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
        IGeneScience(registry.addressOf(CONTRACT_GENE_SCIENCE)).isOkWithRaceAndGender(matron.genes, sire.genes);
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


    function breedWithAuto(uint256 _matronId, uint256 _sireId)
    public
    whenNotPaused
    {
        // Check for payment
        // caller must approve first.
        uint256 autoBirthFee = registry.uintOf(ApostleSettingIds.UINT_AUTOBIRTH_FEE);
        ERC20 ring = ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN));
        require(ring.transferFrom(msg.sender, address(this), autoBirthFee));

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
    function giveBirth(uint256 _matronId, address _resourceToken, uint256 _level)
    public
    isHuman
    whenNotPaused
    {

        Apostle storage matron = tokenId2Apostle[_matronId];
        uint256 sireId = matron.siringWithId;

        if (_resourceToken != address(0)) {
            // users must approve enough resourceToken to this contract
            // if _resourceToken is registered
            // will be checked in mixgenes
            ERC20(_resourceToken).transferFrom(msg.sender, address(this), _level * registry.uintOf(UINT_MIX_TALENT));
        }


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
        (uint256 childGenes, uint256 childTalents) = IGeneScience(registry.addressOf(CONTRACT_GENE_SCIENCE)).mixGenesAndTalents(matron.genes, sire.genes, matron.talents, sire.talents, _resourceToken, _level);

        address owner = ERC721(registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_matronId);
        // Make the new Apostle!
        _createApostle(_matronId, matron.siringWithId, parentGen + 1, childGenes, childTalents, owner);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete matron.siringWithId;

        return true;
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public {
        uint256 autoBirthFee = registry.uintOf(ApostleSettingIds.UINT_AUTOBIRTH_FEE);

        uint matronId;
        uint sireId;
        uint level;

        if (msg.sender == registry.addressOf(CONTRACT_RING_ERC20_TOKEN)) {
            require(_value >= autoBirthFee, 'not enough to breed.');
            ERC223(msg.sender).transfer(registry.addressOf(CONTRACT_REVENUE_POOL), _value, toBytes(_from));

            assembly {
                let ptr := mload(0x40)
                calldatacopy(ptr, 0, calldatasize)
                matronId := mload(add(ptr, 132))
                sireId := mload(add(ptr, 164))
            }

            // All checks passed, apostle gets pregnant!
            _breedWith(matronId, sireId);
            emit AutoBirth(matronId, uint48(tokenId2Apostle[matronId].cooldownEndTime));

        } else if (isValidResourceToken(msg.sender)){

            assembly {
                let ptr := mload(0x40)
                calldatacopy(ptr, 0, calldatasize)
                matronId := mload(add(ptr, 132))
                level := mload(add(ptr, 164))
            }

            require(level > 0 && _value >= level * registry.uintOf(UINT_MIX_TALENT), 'resource for mixing is not enough.');

            sireId = tokenId2Apostle[matronId].siringWithId;

            // TODO: msg.sender must be valid resource tokens, this is now checked in the implement of IGeneScience.
            // better to check add a API in IGeneScience for checking valid msg.sender is one of the resource.
            require(_payAndMix(matronId, sireId, msg.sender, level));

        }

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
        uint talents = tokenId2Apostle[_tokenId].talents;
        return IGeneScience(registry.addressOf(CONTRACT_GENE_SCIENCE))
        .getStrength(talents, _resourceToken, _landTokenId);
    }

    /// IActivityObject
    function activityAdded(uint256 _tokenId, address _activity, address _user) auth public {
        // to active the apostle when it do activity the first time
        if (tokenId2Apostle[_tokenId].activeTime == 0) {
            tokenId2Apostle[_tokenId].activeTime = uint48(now);

            emit Unbox(_tokenId, now);
        }

    }

    function activityRemoved(uint256 _tokenId, address _activity, address _user) auth public {
        // do nothing.
    }

    /// IActivity
    function activityStopped(uint256 _tokenId) auth public {
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

    function toBytes(address x) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), x)}
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
}


