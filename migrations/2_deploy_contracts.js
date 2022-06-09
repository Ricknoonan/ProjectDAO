var SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol");
var Factory = artifacts.require("./SimpleAgreementFactory.sol");

module.exports = function (deployer) {
  deployer.deploy(SimpleContractAgreement).then(() => deployer.deploy(Factory, SimpleContractAgreement.address));
};
