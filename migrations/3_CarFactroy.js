const CF = artifacts.require("CarFactory.sol");

module.exports = function (deployer) {
  deployer.deploy(CF);
};