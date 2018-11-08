pragma solidity ^0.4.24;

import "./interfaces/IApostleBase.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "@evolutionland/common/contracts/interfaces/IObjectOwnership.sol";
import "@evolutionland/common/contracts/interfaces/ISettingsRegistry.sol";
import "@evolutionland/common/contracts/SettingIds.sol";
import "@evolutionland/common/contracts/DSAuth.sol";

contract ApostleBase is DSAuth, SettingIds {
    event Birth(address indexed owner, uint256 kittyId, uint256 matronId, uint256 sireId, uint256 genes, uint256 talents);

    struct Apostle {
        uint256 genes;
        uint256 talents;

        uint32 matronId;
        uint32 sireId;

        uint32 siringWithId;

        uint64 birthTime;

        uint64 cooldownEndTime;

        uint16 cooldownIndex;

        uint16 generation;
    }

    bool private singletonLock = false;

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

    ISettingsRegistry public registry;

    mapping (uint256 => Apostle) public tokenId2Apostle;

    uint256 public lastApostleId;

    /*
     *  Modifiers
     */
    modifier singletonLockCall() {
        require(!singletonLock, "Only can call once");
        _;
        singletonLock = true;
    }

    /**
     * @dev Same with constructor, but is used and called by storage proxy as logic contract.
     */
    function initializeContract(address _registry) public singletonLockCall {
        // Ownable constructor
        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        registry = ISettingsRegistry(_registry);
    }

    function _createApostle(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _genes,
        uint256 _talents,
        address _owner
    )
        internal
        returns (uint _tokenId)
    {
        require(_matronId <= 4294967295);
        require(_sireId <= 4294967295);
        require(_generation <= 65535);

        Apostle memory _apostle = Apostle({
            genes: _genes,
            talents: _talents,
            birthTime: uint64(now),
            cooldownEndTime: 0,
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            siringWithId: 0,
            cooldownIndex: 0,
            generation: uint16(_generation)
        });

        // auto increase object id, start from 1
        lastApostleId += 1;

        require(lastApostleId <= 340282366920938463463374607431768211455, "Can not be stored with 128 bits.");

        _tokenId = IObjectOwnership(registry.addressOf(CONTRACT_OBJECT_OWNERSHIP)).mintObject(_owner, uint128(lastApostleId));

        // It's probably never going to happen, 4 billion cats is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(_tokenId <= 4294967295);

        tokenId2Apostle[_tokenId] = _apostle;

        // emit the birth event
        emit Birth(
            _owner,
            _tokenId,
            uint256(_apostle.matronId),
            uint256(_apostle.sireId),
            _apostle.genes,
            _apostle.talents
        );
    }
}