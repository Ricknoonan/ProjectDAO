const SimpleAgreementFactory = artifacts.require("./SimpleAgreementFactory.sol")
const SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol")


contract("Create Child Agreement", function () {

    it("should assert true", async function () {
        await SimpleAgreementFactory.deployed();
        return assert.isTrue(true);
    });
});

contract("Create Children agreements", async () => {
    let factory;
    beforeEach(async () => {
        factory = await SimpleAgreementFactory.deployed();
    });

    it("should create child agreements", async () => {
        //call factory 
        await factory.createChild(5, 1, 1655609942, 1655869142);
        await factory.createChild(8, 1, 1655609942, 1655869142);
        await factory.createChild(12, 1, 1655609942, 1655869142);
        const children = await factory.getChildren();

        //get children from array 
        const child1 = await SimpleContractAgreement.at(children[0]);
        const child2 = await SimpleContractAgreement.at(children[1]);
        const child3 = await SimpleContractAgreement.at(children[2]);

        //assert data 
        const amount1 = await child1.getPaymentAmount();
        const amount2 = await child2.getPaymentAmount();
        const amount3 = await child3.getPaymentAmount();
        assert.equal(amount1, 5);
        assert.equal(amount2, 8);
        assert.equal(amount3, 12);
        assert.equal(children.length, 3);
    })
})