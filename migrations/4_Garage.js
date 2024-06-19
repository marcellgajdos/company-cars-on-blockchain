const G = artifacts.require("Garage.sol");

module.exports = function (deployer) {
  deployer.deploy(G);
};