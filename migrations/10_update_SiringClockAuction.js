const Proxy = artifacts.require('OwnedUpgradeabilityProxy');
const SiringClockAuction = artifacts.require('SiringClockAuctionV2');

const conf = {
    siringClockAuctionProxy_address: '0x439f118c4ade15ad011f2b8d2350af70fa3046dc'
}

module.exports = async(deployer, network) => {

    if(network != 'kovan') {
        return;
    }

    deployer.deploy(SiringClockAuction).then(async() => {
        await Proxy.at(conf.siringClockAuctionProxy_address).upgradeTo(SiringClockAuction.address);
    })


}