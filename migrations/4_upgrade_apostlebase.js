const Proxy = artifacts.require('OwnedUpgradeabilityProxy');
const ApostleBase = artifacts.require('ApostleBase');

const conf = {
    apostleBaseProxy_address: '0x23236af7d03c4b0720f709593f5ace0ea92e77cf'
}

module.exports = async(deployer, network) => {

    if(network != 'kovan') {
        return;
    }

    deployer.deploy(ApostleBase).then(async() => {
        await Proxy.at(conf.apostleBaseProxy_address).upgradeTo(ApostleBase.address);
    })


}