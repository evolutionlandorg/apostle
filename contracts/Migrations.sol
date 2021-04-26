pragma solidity ^0.4.23;
import "@evolutionland/common/contracts/ObjectOwnershipAuthority.sol";
import '@evolutionland/common/contracts/SettingsRegistry.sol';
import "@evolutionland/common/contracts/ObjectOwnership.sol";
import "@evolutionland/common/contracts/InterstellarEncoderV3.sol";
import "@evolutionland/common/contracts/InterstellarEncoderV2.sol";
// import "@evolutionland/upgraeability-using-unstructured-storage/contracts/OwnedUpgradeabilityProxy.sol";
import "@evolutionland/common/contracts/ERC721Bridge.sol";

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
