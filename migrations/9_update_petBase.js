const Proxy = artifacts.require('OwnedUpgradeabilityProxy');
const PetBase = artifacts.require('PetBase');

const conf = {
    petBaseProxy_address: '0x9038cf766688c8e9b19552f464b514f9760fdc49'
}

module.exports = async(deployer, network) => {

    if(network != 'kovan') {
        return;
    }

    deployer.deploy(PetBase).then(async() => {
        await Proxy.at(conf.petBaseProxy_address).upgradeTo(PetBase.address);
    })


}