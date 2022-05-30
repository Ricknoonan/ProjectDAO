const assert = require("assert");

const SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol");

contract("Initial State", accounts => {
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

contract("Employee", accounts => {
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

contract("Employer Fund", accounts => {
    it("...should allow the employer to fund the contract with the stake and payment amount", async () => {
        let simpleContractInstance = await SimpleContractAgreement.deployed({ from: accounts[0] });

        let amountPass = 110000;

        //send stake and payment amount to contract
        await simpleContractInstance.setParticpantFunds().send(amountPass, { from: accounts[0] })

        // Check Stake
        let particpant = await simpleContractInstance.particpants(accounts[0])
        assert.equal(particpant.hasStake, true, ("Stake should be set to true due to setParticpantFunds"))


        // Check employer sends correct amount
        assert.equal(particpant.stakeAmount, 1000, ("Stake amount should be 10% of the payment amount"))
        assert.equal(particpant.totalAmount, 11000, ("Total amout of sent by "))

    });

    it("...should not allow the employer to fund the contract with the too low of stake and payment amount", async () => {
        let simpleContractInstance = await SimpleContractAgreement.deployed({ from: accounts[0] });

        let amountFail = 900;

        //send stake and payment amount to contract
        try {
            await simpleContractInstance.setParticpantFunds().send(amountFail, { from: accounts[0] })
            assert.fail("The transaction should have thrown an error");
        } catch (err) {
            assert.include(err.message, "Insufficent amount", "900 is below the stake and payment amount");
        }

    });


});

contract("Employee Fund", accounts => {
    it("...should allow the employee to fund the contract with the stake", async () => {
        let simpleContractInstance = await SimpleContractAgreement.deployed({ from: accounts[0] });

        await simpleContractInstance.setEmployee({ from: accounts[1] });

        let amountPass = 1000;

        //send stake and payment amount to contract
        await simpleContractInstance.setParticpantFunds().send(amountPass, { from: accounts[1] })
    });

    it("...should not allow the employer to fund the contract with the too low of stake and payment amount", async () => {
        let simpleContractInstance = await SimpleContractAgreement.deployed({ from: accounts[0] });

        let amountFail = 900;

        //send stake and payment amount to contract
        try {
            await simpleContractInstance.setParticpantFunds().send(amountPass, { from: accounts[1] })
            assert.fail("The transaction should have thrown an error");
        } catch (err) {
            assert.include(err.message, "Insufficent amount", "900 is below the stake and payment amount");
        }

    });

});

contract("Modify Date", accounts => {
    it("should allow state dates to be changed once both particpants have signed with same dates", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new(10000, 10, 1655609942, 1655869142, { from: accounts[0] });

        await simpleContractInstance.setEmployee({ from: accounts[1] });
        let _startDate = 1655609945;
        let _endDate = 1655869146;
        await simpleContractInstance.modifyDates({ from: accounts[0] }, _startDate, _endDate)
        await simpleContractInstance.modifyDates({ from: accounts[1] }, _startDate, _endDate)
        const startDate = simpleContractInstance.getStartDate()
        assert.equal(startDate, _startDate, "state start date should be updated now")


    });
});


/*
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