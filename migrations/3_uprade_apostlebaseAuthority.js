const ApostleBase = artifacts.require('ApostleBase');
const ApostleBaseAuthority = artifacts.require('ApostleBaseAuthority');

const conf = {
    apostleBaseProxy_address: '0x23236af7d03c4b0720f709593f5ace0ea92e77cf',
    siringClockAuctionProxy_address: '0x439f118c4ade15ad011f2b8d2350af70fa3046dc',
    gen0ApostleProxy_address: '0xd45fe6e402e3c21cd5b3273908121c90a30f5f71',
    tokenUseProxy_address: '0xd2bcd143db59ddd43df2002fbf650e46b2b7ea19'
}

module.exports = async (deployer, network) => {

    if(network == 'kovan') {
        return;
    }

    deployer.deploy(ApostleBaseAuthority,
        [conf.siringClockAuctionProxy_address,
        conf.gen0ApostleProxy_address,
        conf.tokenUseProxy_address])
        .then(async() => {
            await ApostleBase.at(conf.apostleBaseProxy_address).setAuthority(ApostleBaseAuthority.address);
        })
}