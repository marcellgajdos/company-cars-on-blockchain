const HR = artifacts.require("HR.sol");

module.exports = function (deployer) {
  deployer.deploy(HR);
};