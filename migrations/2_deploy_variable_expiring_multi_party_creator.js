const ExpiringMultiPartyCreator = artifacts.require("ExpiringMultiPartyCreator");
const ExpiringMultiPartyLib = artifacts.require("ExpiringMultiPartyLib");
const {
  RegistryRolesEnum,
  interfaceName,
  getKeysForNetwork,
  deploy,
  enableControllableTiming
} = require("@uma/common");

module.exports = async function(deployer, network, accounts) {
  const keys = getKeysForNetwork(network, accounts);
  const controllableTiming = enableControllableTiming(network);

  // hardhat
  if (ExpiringMultiPartyLib.setAsDeployed) {
    const { contract: empLib } = await deploy(deployer, network, ExpiringMultiPartyLib);

    // Due to how truffle-plugin works, it statefully links it
    // and throws an error if its already linked. So we'll just ignore it...
    try {
      await ExpiringMultiPartyCreator.link(empLib);
    } catch (e) {
      // Allow this to fail in the hardhat case.
    }
  } else {
    // Truffle
    await deploy(deployer, network, ExpiringMultiPartyLib);
    await deployer.link(ExpiringMultiPartyLib, ExpiringMultiPartyCreator);
  }

  const { contract: expiringMultiPartyCreator } = await deploy(
    deployer,
    network,
    ExpiringMultiPartyCreator,
    "0x0000000000000000000000000000000000000000",
    "0x0000000000000000000000000000000000000000",
    "0x0000000000000000000000000000000000000000",
    { from: keys.deployer }
  );

  await registry.addMember(RegistryRolesEnum.CONTRACT_CREATOR, expiringMultiPartyCreator.address);
};