const VariableExpiringMultiPartyCreator = artifacts.require("VariableExpiringMultiPartyCreator");
const VariableExpiringMultiPartyLib = artifacts.require("VariableExpiringMultiPartyLib");
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
  if (VariableExpiringMultiPartyLib.setAsDeployed) {
    const { contract: empLib } = await deploy(deployer, network, VariableExpiringMultiPartyLib);

    // Due to how truffle-plugin works, it statefully links it
    // and throws an error if its already linked. So we'll just ignore it...
    try {
      await VariableExpiringMultiPartyCreator.link(empLib);
    } catch (e) {
      // Allow this to fail in the hardhat case.
    }
  } else {
    // Truffle
    await deploy(deployer, network, VariableExpiringMultiPartyLib);
    await deployer.link(VariableExpiringMultiPartyLib, VariableExpiringMultiPartyCreator);
  }

  const { contract: variableExpiringMultiPartyCreator } = await deploy(
    deployer,
    network,
    VariableExpiringMultiPartyCreator,
    "0x0000000000000000000000000000000000000000",
    "0x0000000000000000000000000000000000000000",
    "0x0000000000000000000000000000000000000000",
    { from: keys.deployer }
  );

  await registry.addMember(RegistryRolesEnum.CONTRACT_CREATOR, variableExpiringMultiPartyCreator.address);
};