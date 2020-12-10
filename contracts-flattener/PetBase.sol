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

// Dependency file: @evolutionland/common/contracts/interfaces/INFTAdaptor.sol

// pragma solidity ^0.4.24;


contract INFTAdaptor {
    function toMirrorTokenId(uint256 _originTokenId) public view returns (uint256);

    function toOriginTokenId(uint256 _mirrorTokenId) public view returns (uint256);

    function approveOriginToken(address _bridge, uint256 _originTokenId) public;

    function ownerInOrigin(uint256 _originTokenId) public view returns (address);

    function cacheMirrorTokenId(uint256 _originTokenId, uint256 _mirrorTokenId) public;
}


// Dependency file: @evolutionland/common/contracts/interfaces/IInterstellarEncoderV3.sol

// pragma solidity ^0.4.24;

contract IInterstellarEncoderV3 {
    uint256 constant CLEAR_HIGH =  0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;

    uint256 public constant MAGIC_NUMBER = 42;    // Interstellar Encoding Magic Number.
    uint256 public constant CHAIN_ID = 1; // Ethereum mainet.
    uint256 public constant CURRENT_LAND = 1; // 1 is Atlantis, 0 is NaN.

    enum ObjectClass { 
        NaN,
        LAND,
        APOSTLE,
        OBJECT_CLASS_COUNT
    }

    function registerNewObjectClass(address _objectContract, uint8 objectClass) public;

    function encodeTokenId(address _tokenAddress, uint8 _objectClass, uint128 _objectIndex) public view returns (uint256 _tokenId);

    function encodeTokenIdForObjectContract(
        address _tokenAddress, address _objectContract, uint128 _objectId) public view returns (uint256 _tokenId);

    function encodeTokenIdForOuterObjectContract(
        address _objectContract, address nftAddress, address _originNftAddress, uint128 _objectId, uint16 _producerId, uint8 _convertType) public view returns (uint256);

    function getContractAddress(uint256 _tokenId) public view returns (address);

    function getObjectId(uint256 _tokenId) public view returns (uint128 _objectId);

    function getObjectClass(uint256 _tokenId) public view returns (uint8);

    function getObjectAddress(uint256 _tokenId) public view returns (address);

    function getProducerId(uint256 _tokenId) public view returns (uint16);

    function getOriginAddress(uint256 _tokenId) public view returns (address);

}

// Dependency file: contracts/interfaces/IApostleBase.sol

// pragma solidity ^0.4.24;


// TODO: upgrade common-contacts version then delete this.
contract IApostleBase {
    function createApostle(
        uint256 _matronId, uint256 _sireId, uint256 _generation, uint256 _genes, uint256 _talents, address _owner) public returns (uint256) ;

    function isReadyToBreed(uint256 _apostleId) public view returns (bool);

    function isAbleToBreed(uint256 _matronId, uint256 _sireId, address _owner) public view returns(bool);

    function breedWithInAuction(uint256 _matronId, uint256 _sireId) public returns (bool);

    function canBreedWith(uint256 _matronId, uint256 _sireId) public view returns (bool);

    function getCooldownDuration(uint256 _tokenId) public view returns (uint256);

    function defaultLifeTime(uint256 _tokenId) public view returns (uint256);

    function isDead(uint256 _tokenId) public view returns (bool);

    function approveSiring(address _addr, uint256 _sireId) public;

    function getApostleInfo(uint256 _tokenId) public view returns(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256);

    function updateGenesAndTalents(uint256 _tokenId, uint256 _genes, uint256 _talents) public;
}

// Dependency file: contracts/interfaces/IERC721Bridge.sol

// pragma solidity ^0.4.24;

contract IERC721Bridge {


    function originNft2Adaptor(address _originContract) public view returns (address);

    function ownerOf(uint256 _mirrorTokenId) public view returns (address);

    function isBridged(uint256 _mirrorTokenId) public view returns (bool);

    function bridgeInAuth(address _originNftAddress, uint256 _originTokenId, address _owner) public returns (uint256);
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


// Dependency file: contracts/interfaces/ILandResource.sol

// pragma solidity ^0.4.23;

contract ILandResource {

    function updateMinerStrengthWhenStart(uint256 _apostleTokenId) public;

    function updateMinerStrengthWhenStop(uint256 _apostleTokenId) public;

    function landWorkingOn(uint256 _apostleTokenId) public view returns (uint256);
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


// Dependency file: openzeppelin-solidity/contracts/math/SafeMath.sol

// pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
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


// Dependency file: @evolutionland/common/contracts/interfaces/IObjectOwnership.sol

// pragma solidity ^0.4.24;

contract IObjectOwnership {
    function mintObject(address _to, uint128 _objectId) public returns (uint256 _tokenId);

    function burnObject(address _to, uint128 _objectId) public returns (uint256 _tokenId);
}

// Root file: contracts/pet/PetBase.sol

pragma solidity ^0.4.24;

// import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
// import "@evolutionland/common/contracts/interfaces/INFTAdaptor.sol";
// import "@evolutionland/common/contracts/interfaces/IInterstellarEncoderV3.sol";
// import "contracts/interfaces/IApostleBase.sol";
// import "contracts/interfaces/IERC721Bridge.sol";
// import "contracts/interfaces/IGeneScience.sol";
// import "contracts/interfaces/ILandResource.sol";
// import "contracts/ApostleSettingIds.sol";
// import "openzeppelin-solidity/contracts/math/SafeMath.sol";
// import "@evolutionland/common/contracts/PausableDSAuth.sol";
// import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
// import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";

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

        address objectOwnership = registry.addressOf(SettingIds.CONTRACT_OBJECT_OWNERSHIP);

        // if this pet is inside evoland
        // it will also be considered in erc721Bridge
        require(IERC721Bridge(erc721Bridge).ownerOf(_petTokenId) == _owner || ERC721(objectOwnership).ownerOf(_apostleTokenId) == _owner, "you have no right.");


        // TODO: update mine
        // changed - true
        bool changed = _talents == _modifiedTalents ? false : true;
        if (changed) {
            address landResource = registry.addressOf(CONTRACT_LAND_RESOURCE);
            if (ILandResource(landResource).landWorkingOn(_apostleTokenId) != 0) {
                // true means minus strength
                ILandResource(landResource).updateMinerStrengthWhenStop(_apostleTokenId);
            }

            IApostleBase(registry.addressOf(CONTRACT_APOSTLE_BASE)).updateGenesAndTalents(_apostleTokenId, _genes, _modifiedTalents);

            if (ILandResource(landResource).landWorkingOn(_apostleTokenId) != 0) {
                ILandResource(landResource).updateMinerStrengthWhenStart(_apostleTokenId);
            }
        }

        return changed;
    }

    function untiePetToken(uint256 _petTokenId) public {
        uint256 apostleTokenId = pet2TiedStatus[_petTokenId].apostleTokenId;

        // if pet is not tied, do nothing
        if(apostleTokenId == 0) {
            return;
        }

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

    function getTiedPet(uint256 _apostleTokenId, uint256 _index) public view returns (uint256) {
        return tokenId2PetStatus[_apostleTokenId].tiedList[_index];
    }

}
