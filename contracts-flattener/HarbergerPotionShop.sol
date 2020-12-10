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

// Dependency file: @evolutionland/common/contracts/interfaces/IBurnableERC20.sol

// pragma solidity ^0.4.23;

contract IBurnableERC20 {
    function burn(address _from, uint _value) public;
}

// Dependency file: @evolutionland/common/contracts/interfaces/IMintableERC20.sol

// pragma solidity ^0.4.23;

contract IMintableERC20 {

    function mint(address _to, uint256 _value) public;
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

// Root file: contracts/HarbergerPotionShop.sol

pragma solidity ^0.4.24;

// import "openzeppelin-solidity/contracts/math/SafeMath.sol";
// import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
// import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
// import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
// import "@evolutionland/common/contracts/interfaces/IBurnableERC20.sol";
// import "@evolutionland/common/contracts/interfaces/IMintableERC20.sol";
// import "@evolutionland/common/contracts/DSAuth.sol";
// import "contracts/ApostleSettingIds.sol";
// import "contracts/interfaces/IApostleBase.sol";

contract  HarbergerPotionShop is DSAuth, ApostleSettingIds {
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
        uint256 availablePotionFund;
        uint48 startTime;
        uint48 boughtLifeTime;
        uint48 lastUpdateTime;
        bool isDead;
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

        
        address apostleBase = registry.addressOf(CONTRACT_APOSTLE_BASE);
        require(!(IApostleBase(apostleBase).isDead(_tokenId)), "Apostle is dead, can not start Haberg.");

        require(tokenId2PotionState[_tokenId].lastUpdateTime == 0, "Potion model should not started yet.");
        require(_estimatePrice > 0, "Apostle estimated price must larger than zero.");

        ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(msg.sender, address(this), _ringAmount);

        tokenId2PotionState[_tokenId] = PotionState({
            estimatePrice: _estimatePrice,
            availablePotionFund: _ringAmount,
            startTime: uint48(IApostleBase(apostleBase).defaultLifeTime(_tokenId)),
            boughtLifeTime: 0,
            lastUpdateTime: uint48(now),
            isDead: false
        });
    }

    function tryKillApostle(uint256 _tokenId, address _killer) public auth {
        if (tokenId2PotionState[_tokenId].lastUpdateTime == 0) {
            // didn't start hargberg or already exited.
            return;
        } else if (tokenId2PotionState[_tokenId].isDead) {
            return;
        } else {
            uint256 currentHarbergLifeTime = harbergLifeTime(_tokenId);
            require(currentHarbergLifeTime < now);

            tokenId2PotionState[_tokenId].isDead = true;
            tokenId2PotionState[_tokenId].boughtLifeTime += uint48(currentHarbergLifeTime - tokenId2PotionState[_tokenId].startTime);
            tokenId2PotionState[_tokenId].availablePotionFund = 0;
            tokenId2PotionState[_tokenId].lastUpdateTime = uint48(now);
        }
    }

    // deposit haberg tax
    function buyPotion(uint256 _tokenId, uint256 _ringAmount) public {
        require(ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).ownerOf(_tokenId) == msg.sender, "Only apostle owner can buy potion.");

        _buyPotion(msg.sender, _tokenId, _ringAmount);
    }

    function _buyPotion(address _payer, uint256 _tokenId, uint256 _ringAmount) internal {
        require(tokenId2PotionState[_tokenId].lastUpdateTime > 0, "Potion model does not exist.");
        require(!tokenId2PotionState[_tokenId].isDead, "Apostle must not be dead.");

        ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(_payer, address(this), _ringAmount);

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

        uint256 usedPotionFund = tokenId2PotionState[_tokenId].estimatePrice
            .mul(registry.uintOf(UINT_HABERG_POTION_TAX_RATE)).div(100000000)
            .mul(newBoughtLifeTime).div(1 days);

        tokenId2PotionState[_tokenId].availablePotionFund = tokenId2PotionState[_tokenId].availablePotionFund.sub(usedPotionFund);

        tokenId2PotionState[_tokenId].boughtLifeTime = uint48(tokenId2PotionState[_tokenId].boughtLifeTime + newBoughtLifeTime);

        tokenId2PotionState[_tokenId].lastUpdateTime = uint48(now);
    }

    /// stop Haberg will kill the apostle
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

        uint256 oldAvailablePotionFund = tokenId2PotionState[_tokenId].availablePotionFund;

        /// new owner must make up the potion fee if the old owner didn't pay enough
        _buyPotion(msg.sender, _tokenId, _depositPotionFee);

        _updateHabergPotionState(_tokenId);

        uint256 usedFund = oldAvailablePotionFund + _depositPotionFee - tokenId2PotionState[_tokenId].availablePotionFund;

        if (oldAvailablePotionFund > usedFund) {
            ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(
                address(this), tokenOwner, (oldAvailablePotionFund - usedFund)
            );
        }

        ERC20(registry.addressOf(CONTRACT_RING_ERC20_TOKEN)).transferFrom(
            msg.sender, tokenOwner, tokenId2PotionState[_tokenId].estimatePrice);

        // must approve this first, if not, others can kill this apostle in Apostle.
        ERC721(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).transferFrom(tokenOwner, msg.sender, _tokenId);
    }

    function harbergLifeTime(uint256 _tokenId) public view returns (uint256) {
        return tokenId2PotionState[_tokenId].startTime + tokenId2PotionState[_tokenId].boughtLifeTime + tokenId2PotionState[_tokenId].availablePotionFund
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
