const VariableExpiringMultiPartyCreator = artifacts.require("VariableExpiringMultiPartyCreator");
const VariableExpiringMultiPartyLib = artifacts.require("VariableExpiringMultiPartyLib");
/*const Finder = artifacts.require("Finder");
const TokenFactory = artifacts.require("TokenFactory");

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



  await deploy(deployer, network, Finder)
  // Add CollateralWhitelist to finder.
  const finder = await Finder.deployed();


  await finder.changeImplementationAddress(
    web3.utils.utf8ToHex(interfaceName.CollateralWhitelist),
    "0x0000000000000000000000000000000000000000", // collateralWhitelist.address,
    {
      from: keys.deployer,
    }
  );


  await deploy(deployer, network, TokenFactory)

  const tokenFactory = await TokenFactory.deployed();



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
    console.log("DEPLOY LIB")
    await deploy(deployer, network, VariableExpiringMultiPartyLib);
    await deployer.link(VariableExpiringMultiPartyLib, VariableExpiringMultiPartyCreator);
  }

  const { contract: variableExpiringMultiPartyCreator } = await deploy(
    deployer,
    network,
    VariableExpiringMultiPartyCreator,
    finder.address,
    tokenFactory.address,
    "0x0000000000000000000000000000000000000000",
    { from: keys.deployer }
  );

};
*/

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
    "0x40f941E48A552bF496B154Af6bf55725f18D77c3",
    "0x7c96d6235CfaaCcAc5d80fCe74E6032B25dd1F03",
    "0x0000000000000000000000000000000000000000",
    { from: keys.deployer }
  );

};