const CryptoKittiesAdaptor = artifacts.require("CryptoKittiesAdaptor");
const Proxy = artifacts.require("OwnedUpgradeabilityProxy");
const SettingsRegistry = artifacts.require("SettingsRegistry");
const CryptoKittiesAdaptorAuthority = artifacts.require("CryptoKittiesAdaptorAuthority");
const InterstellarEncoderV3 = artifacts.require('InterstellarEncoderV3');
const ERC721Bridge = artifacts.require("ERC721Bridge");

const conf = {
    registry_address: "0xd8b7a3f6076872c2c37fb4d5cbfeb5bf45826ed7",
    kittyCore_address: "0x9782865f91f9aace5582f695bf678121a0359edd",
    erc721BridgeProxy_address: "0xd62886b4e194da252dd407868964478eb1b89432",
    interstellarEncoderV3_address: "0xc26828ecdd676f40431eceb687bdacec6afa73a6",
    cryptoKitties_class: 3,
    ck_producer_id: 128
}

var ckAdaptorProxy_address;

module.exports = async (deployer, network) => {

    if (network != "kovan") {
        return;
    }

    deployer.deploy(Proxy).then(async() => {
        let ckAdaptorProxy = await Proxy.deployed();
        ckAdaptorProxy_address = ckAdaptorProxy.address;
        console.log("ckAdaptorProxy: ", ckAdaptorProxy_address);
        await deployer.deploy(CryptoKittiesAdaptor);
        await deployer.deploy(CryptoKittiesAdaptorAuthority, [conf.erc721BridgeProxy_address]);
    }).then(async() => {

        // upgrade
        let proxy = await Proxy.at(ckAdaptorProxy_address);
        await proxy.upgradeTo(CryptoKittiesAdaptor.address);
        console.log("111");

        // initialize
        let ckAdaptorProxy = await CryptoKittiesAdaptor.at(ckAdaptorProxy_address);
        await ckAdaptorProxy.initializeContract(conf.registry_address, conf.kittyCore_address, conf.ck_producer_id);
        console.log("222");

        // setAuthority
        await ckAdaptorProxy.setAuthority(CryptoKittiesAdaptorAuthority.address);

        console.log("333");
        // register token address
        let interstellarEncoderV3 = await InterstellarEncoderV3.at(conf.interstellarEncoderV3_address);
        // await interstellarEncoderV3.registerNewTokenContract(conf.kittyCore_address);
        await interstellarEncoderV3.registerNewObjectClass(ckAdaptorProxy_address, conf.cryptoKitties_class);

        console.log("444");

        // register in ERC721Bridge
        let bridge = await ERC721Bridge.at(conf.erc721BridgeProxy_address);
        await bridge.registerAdaptor(conf.kittyCore_address, ckAdaptorProxy_address);

        console.log("555");
    })

}