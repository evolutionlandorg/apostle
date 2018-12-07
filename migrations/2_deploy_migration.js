const Proxy = artifacts.require('OwnedUpgradeabilityProxy');
const ApostleBase = artifacts.require('ApostleBase');
const ApostleSettingIds = artifacts.require('ApostleSettingIds');
const ApostleClockAuction = artifacts.require('ApostleClockAuction');
const SiringClockAuction = artifacts.require('SiringClockAuction');
const Gen0Apostle = artifacts.require('Gen0Apostle');
const SettingsRegistry = artifacts.require('SettingsRegistry');
const ObjectOwnershipAuthority = artifacts.require('ObjectOwnershipAuthority');
const ObjectOwnership = artifacts.require('ObjectOwnership');
const InterstellarEncoderV2 = artifacts.require('InterstellarEncoderV2');
const ApostleBaseAuthority = artifacts.require('ApostleBaseAuthority');
const ClockAuctionAuthority = artifacts.require('ClockAuctionAuthority');

const conf = {
    registry_address: '0xd8b7a3f6076872c2c37fb4d5cbfeb5bf45826ed7',
    objectOwnershipProxy_address: '0xe94b9ebf9609a0d20270e8de317381ff4bcdcd79',
    landBaseProxy_address: '0x72eec3a6a9a8628e0f7a2dbbad5df083bd985c5f',
    landObject_class: 1,
    apostleObject_class: 2,
    autoBirthFee: 500 * 10 ** 18,
    resourceNeededPerLevel: 5 * 10 ** 18,
    bidWaitingTime: 10 * 60,
    gen0Limit: 2000
}

let apostleBaseProxy_address;
let clockAuctionProxy_address;
let gen0ApostleProxy_address;
let siringClockAuctionProxy_address;

module.exports = async (deployer, network) => {
    if (network == 'kovan') {
        return;
    }

    deployer.deploy(InterstellarEncoderV2);
    deployer.deploy(ApostleSettingIds);
    deployer.deploy(Proxy
    ).then(async () => {
        let apostleProxy = await Proxy.deployed();
        apostleBaseProxy_address = apostleProxy.address;
        console.log('ApostleBaseProxy: ', apostleBaseProxy_address);
        await deployer.deploy(ApostleBase);
        await deployer.deploy(Proxy)
    }).then(async () => {
        let clockAuctionProxy = await Proxy.deployed();
        clockAuctionProxy_address = clockAuctionProxy.address;
        console.log('ClockAuctionProxy: ', clockAuctionProxy_address);
        await deployer.deploy(ApostleClockAuction);
        await deployer.deploy(Proxy);
    }).then(async () => {
        let gen0ApostleProxy = await Proxy.deployed();
        gen0ApostleProxy_address = gen0ApostleProxy.address;
        console.log('Gen0ApostleProxy: ', gen0ApostleProxy_address);
        await deployer.deploy(Gen0Apostle);
        await deployer.deploy(Proxy);
    }).then(async () => {
        let siringClockAuctionProxy = await Proxy.deployed();
        siringClockAuctionProxy_address = siringClockAuctionProxy.address;
        console.log('SiringClockAuctionProxy: ', siringClockAuctionProxy_address);
        await deployer.deploy(SiringClockAuction);
        // deploy authorities
        await deployer.deploy(ObjectOwnershipAuthority, [conf.landBaseProxy_address, apostleBaseProxy_address]);
        await deployer.deploy(ClockAuctionAuthority, [gen0ApostleProxy_address]);
        await deployer.deploy(ApostleBaseAuthority, [gen0ApostleProxy_address, siringClockAuctionProxy_address]);
    }).then(async () => {
        let registry = await SettingsRegistry.at(conf.registry_address);
        let apostleSettingIds = await ApostleSettingIds.deployed();

        // register in registry
        let apostleBaseId = await apostleSettingIds.CONTRACT_APOSTLE_BASE.call();
        await registry.setAddressProperty(apostleBaseId, apostleBaseProxy_address);

        let clockAuctionId = await apostleSettingIds.CONTRACT_APOSTLE_AUCTION.call();
        await registry.setAddressProperty(clockAuctionId, clockAuctionProxy_address);

        let siringAuctionId = await apostleSettingIds.CONTRACT_SIRING_AUCTION.call();
        await registry.setAddressProperty(siringAuctionId, siringClockAuctionProxy_address);

        let birthFeeId = await apostleSettingIds.UINT_AUTOBIRTH_FEE.call();
        await registry.setUintProperty(birthFeeId, conf.autoBirthFee);

        let mixTalentId = await apostleSettingIds.UINT_MIX_TALENT.call();
        await registry.setUintProperty(mixTalentId, conf.resourceNeededPerLevel);

        let bidWaitingTimeId = await apostleSettingIds.UINT_APOSTLE_BID_WAITING_TIME.call();
        await registry.setUintProperty(bidWaitingTimeId, conf.bidWaitingTime);

        let interstellarId = await apostleSettingIds.CONTRACT_INTERSTELLAR_ENCODER.call();
        await registry.setAddressProperty(interstellarId, InterstellarEncoderV2.address);

        console.log("REGISTER DONE!");

        // upgrade
        await Proxy.at(apostleBaseProxy_address).upgradeTo(ApostleBase.address);
        await Proxy.at(clockAuctionProxy_address).upgradeTo(ApostleClockAuction.address);
        await Proxy.at(gen0ApostleProxy_address).upgradeTo(Gen0Apostle.address);
        await Proxy.at(siringClockAuctionProxy_address).upgradeTo(SiringClockAuction.address);

        console.log("UPGRADE DONE!");

        // initialize
        let apostleBaseProxy = await ApostleBase.at(apostleBaseProxy_address);
        let clockAuctionProxy = await ApostleClockAuction.at(clockAuctionProxy_address);
        let gen0ApostleProxy = await Gen0Apostle.at(gen0ApostleProxy_address);
        let siringClockAuctionProxy = await SiringClockAuction.at(siringClockAuctionProxy_address);

        await apostleBaseProxy.initializeContract(registry.address);
        await clockAuctionProxy.initializeContract(registry.address);
        await gen0ApostleProxy.initializeContract(registry.address, conf.gen0Limit);
        await siringClockAuctionProxy.initializeContract(registry.address);

        console.log("INITIALIZE DONE!");

        // set authority
        let objectOwnership = await ObjectOwnership.at(conf.objectOwnershipProxy_address);
        await objectOwnership.setAuthority(ObjectOwnershipAuthority.address);

        await apostleBaseProxy.setAuthority(ApostleBaseAuthority.address);
        await clockAuctionProxy.setAuthority(ClockAuctionAuthority.address);

        // register object contract address in interstellarEncoder
        let interstellarEncoder = await InterstellarEncoderV2.deployed();
        await interstellarEncoder.registerNewTokenContract(conf.objectOwnershipProxy_address);
        await interstellarEncoder.registerNewObjectClass(conf.landBaseProxy_address, conf.landObject_class);
        await interstellarEncoder.registerNewObjectClass(apostleBaseProxy_address, conf.apostleObject_class);

        console.log('MIGRATION SUCCESS!');

    })
}