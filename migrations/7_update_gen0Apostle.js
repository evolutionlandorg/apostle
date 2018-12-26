const Proxy = artifacts.require('OwnedUpgradeabilityProxy');
const Gen0ApostleV2 = artifacts.require('Gen0ApostleV2');

const conf = {
    gen0ApostleProxy_address: '0xd45fe6e402e3c21cd5b3273908121c90a30f5f71'
}

module.exports = async(deployer, network) => {

    if(network != 'kovan') {
        return;
    }

    deployer.deploy(Gen0ApostleV2).then(async() => {
        await Proxy.at(conf.gen0ApostleProxy_address).upgradeTo(Gen0ApostleV2.address);
    })


}