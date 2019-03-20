const ApostleBaseV2 = artifacts.require("ApostleBaseV2");
const ApostleBaseAuthorityV2 = artifacts.require("ApostleBaseAuthorityV2");


const conf = {
    registry_address: "0xd8b7a3f6076872c2c37fb4d5cbfeb5bf45826ed7",
    kittyCore_address: "0x9782865f91f9aace5582f695bf678121a0359edd",
    erc721BridgeProxy_address: "0x3af088062a6ab3b9706eb1c58506fc0fcf898588",
    interstellarEncoderV3_address: "0x0700fa0c70ada58ad708e7bf93d032f1fd9a5150",
    tokenUseProxy_address: "0xd2bcd143db59ddd43df2002fbf650e46b2b7ea19",
    apostleBaseProxy_address: "0x23236af7d03c4b0720f709593f5ace0ea92e77cf",
    gen0ApostleProxy_address: "0xd45fe6e402e3c21cd5b3273908121c90a30f5f71",
    pet_objectClass: 3,
    pet_max_number: 1
}

module.exports = async(deployer, network) => {

    if(network != 'kovan') {
        return;
    }

    deployer.deploy(ApostleBaseAuthorityV2, [conf.tokenUseProxy_address, conf.gen0ApostleProxy_address, conf.petBaseProxy_address]).then(async() => {
        let apostleBase = await ApostleBaseV2.at(conf.apostleBaseProxy_address);
        await apostleBase.setAuthority(ApostleBaseAuthorityV2.address);
    })


}

