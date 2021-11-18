pragma solidity ^0.4.24;
import "@evolutionland/common/contracts/SettingIds.sol";


contract ApostleSettingIds is SettingIds {

    bytes32 public constant CONTRACT_GENE_SCIENCE = "CONTRACT_GENE_SCIENCE";

    /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
    ///  the gas cost paid by the auto-birth daemon, and can be dynamically updated by
    ///  the COO role as the gas price changes.
    bytes32 public constant UINT_AUTOBIRTH_FEE = "UINT_AUTOBIRTH_FEE";

    bytes32 public constant UINT_CHANGECLASS_FEE = "UINT_CHANGECLASS_FEE";

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


    bytes32 public constant CONTRACT_GEN0_APOSTLE = "CONTRACT_GEN0_APOSTLE";

	uint8 public constant ITEM_OBJECT_CLASS = 5; // Item
	uint8 public constant EQUIPMENT_OBJECT_CLASS = 6; //Equipment
}
