const PetBase = artifacts.require("PetBase");
const Proxy = artifacts.require("OwnedUpgradeabilityProxy");
const SettingsRegistry = artifacts.require("SettingsRegistry");
const InterstellarEncoderV3 = artifacts.require('InterstellarEncoderV3');
const ERC721Bridge = artifacts.require("ERC721Bridge");
const ERC721BridgeAuthority = artifacts.require("ERC721BridgeAuthority");

const conf = {
    registry_address: "0xd8b7a3f6076872c2c37fb4d5cbfeb5bf45826ed7",
    kittyCore_address: "0x9782865f91f9aace5582f695bf678121a0359edd",
    erc721BridgeProxy_address: "0x3af088062a6ab3b9706eb1c58506fc0fcf898588",
    interstellarEncoderV3_address: "0x0700fa0c70ada58ad708e7bf93d032f1fd9a5150",
    pet_objectClass: 3,
    pet_max_number: 1
}

var petBaseProxy_address;

module.exports = async (deployer, network) => {

    if (network != "kovan") {
        return;
    }

    deployer.deploy(Proxy).then(async() => {
        let petBaseProxy = await Proxy.deployed();
        petBaseProxy_address = petBaseProxy.address;
        console.log("PetBaseProxy: ", petBaseProxy_address);
        await deployer.deploy(PetBase);
    }).then(async() => {
        await deployer.deploy(ERC721BridgeAuthority, [petBaseProxy_address]);
    }).then(async() => {
        // register
        let registry = await SettingsRegistry.at(conf.registry_address);
        let petBaseLogic = await PetBase.deployed();
        let petBaseId = await petBaseLogic.CONTRACT_PET_BASE.call();
        await registry.setAddressProperty(petBaseId, petBaseProxy_address);
        console.log("REGISTER IN REGISTRY DONE!");

        // upgrade
        let proxy = await Proxy.at(petBaseProxy_address);
        await proxy.upgradeTo(PetBase.address);
        console.log("UPGRADE DONE!");

        // initialize
        let petBaseProxy = await PetBase.at(petBaseProxy_address);
        await petBaseProxy.initializeContract(conf.registry_address, conf.pet_max_number);
        console.log("INITIALIZATION DONE!");

        // setAuthority
        let bridge = await ERC721Bridge.at(conf.erc721BridgeProxy_address);
        await bridge.setAuthority(ERC721BridgeAuthority.address);
        console.log("AUTHORITY DONE!");


        // register token address
        let interstellarEncoderV3 = await InterstellarEncoderV3.at(conf.interstellarEncoderV3_address);
        await interstellarEncoderV3.registerNewObjectClass(petBaseProxy_address, conf.pet_objectClass);

        console.log("ENCODER REGISTER DONE!");


        console.log("SUCCESS!");
    })

}