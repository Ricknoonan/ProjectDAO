var SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol");

module.exports = function (deployer) {
    deployer.deploy(SimpleContractAgreement);
};