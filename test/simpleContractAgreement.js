const SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol");

contract("SimpleContractAgreement", accounts => {
    it("...should set Constructor variables", async () => {
        let simpleContractInstance = await SimpleContractAgreement.deployed();

        //StartDate
        const startDate = await simpleContractInstance.getStartDate();
        assert.equal(startDate, 1655609942, "starDate is 1655609942");

        //EndDate
        const endDate = await simpleContractInstance.getEndDate();
        assert.equal(endDate, 1655869142, "endDate is 1655869142");

        //Payment Amount
        const paymentAmount = await simpleContractInstance.getPaymentAmount();
        assert.equal(paymentAmount, 10000, "paymentAmount is 10000");

        //Stake Amount
        let stakeAmount = await simpleContractInstance.getStakePercent();
        assert.equal(stakeAmount, 10, "stakeAmount is 1000");

    });
});

contract("SimpleContractAgreement", accounts => {
    it("...should set the employee", async () => {
        let simpleContractInstance = await SimpleContractAgreement.deployed({ from: accounts[0] });

        await simpleContractInstance.setEmployee({ from: accounts[1] });

        // Check Stake
        let particpant = await simpleContractInstance.particpants(accounts[1])
        assert.equal(particpant.hasStake, false, ("Stake should be set to fault when initialising employee"))

        // Check Employee address
        let employeeAddr = await simpleContractInstance.particpants(accounts[1])
        assert.equal(employeeAddr.particpantAddr, accounts[1], ("Set with msg sender address"))

        // Check is Employer
        let isEmployer = await simpleContractInstance.particpants(accounts[1])
        assert.equal(isEmployer.isEmployer, false, ("Set with is employer to false"))

        // Check is Employer
        let employerCounter = await simpleContractInstance.getEmployeeCounter()
        assert.equal(employerCounter, 1, ("Employee counter should now be one"))


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