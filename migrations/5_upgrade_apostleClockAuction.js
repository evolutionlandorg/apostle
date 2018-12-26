const Proxy = artifacts.require('OwnedUpgradeabilityProxy');
const ApostleClockAuction = artifacts.require('ApostleClockAuction');

const conf = {
    apostleClockAuctionProxy_address: '0x2fdd8e8da34a8242c04b3d8d6afcb2a6c3afd483'
}

module.exports = async(deployer, network) => {

    if(network == 'kovan') {
        return;
    }

    deployer.deploy(ApostleClockAuction).then(async() => {
        await Proxy.at(conf.apostleClockAuctionProxy_address).upgradeTo(ApostleClockAuction.address);
    })


}