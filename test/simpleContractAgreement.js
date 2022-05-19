const SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol");

contract("SimpleContractAgreement", accounts => {
    it("...should set Constructor variables", async () => {
        const simpleContractInstance = await SimpleContractAgreement.deployed();

        // Set Contract Months
        //require(_startDate < _endDate);
        //employer = msg.sender;
        //paymentAmount = _paymentAmount;
        //stakeAmount = (_stakePercent / 100) * paymentAmount;

        //StartDate
        const startDate = await simpleContractInstance.getStartDate.call();
        assert.equal(startDate, 1655609942, "Start Date is 1655609942");

        //EndDate
        const endDate = await simpleContractInstance.getEndDate.call();
        assert.equal(endDate, 1655869142, "end Date is 1655869142");

    });
});

/*
contract("SimpleContractAgreement", accounts => {
    it("...should set Contract Months as 2", async () => {
        const simpleContractInstance = await SimpleContractAgreement.deployed();

        await simpleContractInstance.setEmployer({ from: accounts[0] });
        // Set Contract Months

        try {
            await simpleContractInstance.setContractMonths(2, { from: accounts[1] });
            assert.fail("The transaction should have thrown an error");
        } catch (err) {
            assert.include(err.message, "Only Employer allowed to call this function", "The error should be OnlyEmployer error message");
        }
        // set contract length as an account that is not the employer

        // set contract length as an account that is the employer
        await simpleContractInstance.setContractMonths(2, { from: accounts[0] });

        // GetContract Months
        const months = await simpleContractInstance.getContractMonths.call();

        assert.equal(months, 2, "Contract Months is now 2");
    });
});

contract("SimpleContractAgreement", accounts => {
    it("...should not set Employer and then set Employee from the same account", async () => {
        const simpleContractInstance = await SimpleContractAgreement.deployed();

        await simpleContractInstance.setEmployer({ from: accounts[0] });

        try {
            await simpleContractInstance.setEmployee({ from: accounts[0] });
            assert.fail("The transaction should have thrown an error");
        } catch (err) {
            assert.include(err.message, "Employer not allowed to call this function", "The error should be notEmployer error message");
        }

    });
});

contract("SimpleContractAgreement", accounts => {
    it("...should not set Employee and then set Employer from the same account", async () => {
        const simpleContractInstance = await SimpleContractAgreement.deployed();

        await simpleContractInstance.setEmployee({ from: accounts[0] });

        try {
            await simpleContractInstance.setEmployer({ from: accounts[0] });
            assert.fail("The transaction should have thrown an error");
        } catch (err) {
            assert.include(err.message, "Employee not allowed to call this function", "The error should be notEmployee error message");
        }

    });
});

contract("SimpleContractAgreement", accounts => {
    it("...should set Payment amount as 10000", async () => {
        const simpleContractInstance = await SimpleContractAgreement.deployed();

        await simpleContractInstance.setEmployer({ from: accounts[0] });

        try {
            await simpleContractInstance.setPaymentAmount(10000, { from: accounts[1] });
            assert.fail("The transaction should have thrown an error");
        } catch (err) {
            assert.include(err.message, "Only Employer allowed to call this function", "The error should be OnlyEmployer error message");
        }

        await simpleContractInstance.setPaymentAmount(10000, { from: accounts[0] });

        const months = await simpleContractInstance.getPaymentAmount.call();

        assert.equal(months, 10000, "Payment amount is now 10000");
    });
});

*/