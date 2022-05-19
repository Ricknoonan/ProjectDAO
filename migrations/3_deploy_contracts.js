var SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol");

module.exports = function (deployer) {
    deployer.deploy(SimpleContractAgreement, 10000, 10, 1655609942, 1655869142);
};