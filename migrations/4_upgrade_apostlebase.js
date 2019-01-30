const Proxy = artifacts.require('OwnedUpgradeabilityProxy');
const ApostleBaseV2 = artifacts.require('ApostleBaseV2');

const conf = {
    apostleBaseProxy_address: '0x23236af7d03c4b0720f709593f5ace0ea92e77cf'
}

module.exports = async(deployer, network) => {

    if(network == 'kovan') {
        return;
    }

    deployer.deploy(ApostleBaseV2).then(async() => {
        await Proxy.at(conf.apostleBaseProxy_address).upgradeTo(ApostleBaseV2.address);
    })


}