const SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol");

/*contract("Initial State", accounts => {
    it("...should set Constructor variables", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new(10, 1, 1655609942, 1655869142, { from: accounts[0] });

        //StartDate
        const startDate = await simpleContractInstance.getStartDate();
        assert.equal(startDate, 1655609942, "starDate is 1655609942");

        //EndDate
        const endDate = await simpleContractInstance.getEndDate();
        assert.equal(endDate, 1655869142, "endDate is 1655869142");

        //Payment Amount
        const paymentAmount = await simpleContractInstance.getPaymentAmount();
        assert.equal(paymentAmount, 10, "paymentAmount is 10");

        //Stake Amount
        let stakeAmount = await simpleContractInstance.getStakeAmount();
        assert.equal(stakeAmount, 1, "stakeAmount is 1");

    });
});

contract("Employee", accounts => {
    it("...should set the employee", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new(10, 1, 1655609942, 1655869142, { from: accounts[0] });

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
        const simpleContractInstance = await SimpleContractAgreement.new(10, 1, 1655609942, 1655869142, { from: accounts[0] });
        let amountPass = 11;

        await simpleContractInstance.setEmployee({ from: accounts[1] });

        //send stake and payment amount to contract
        await simpleContractInstance.setParticpantFunds({ from: accounts[0], value: amountPass })

        // Check Stake
        let particpant = await simpleContractInstance.particpants(accounts[0])
        assert.equal(particpant.hasStake, true, ("Stake should be set to true due to setParticpantFunds"))


        // Check employer sends correct amount
        assert.equal(particpant.stakeAmount, 1, ("Stake amount should be 10% of the payment amount"))
        assert.equal(particpant.totalAmount, 11, ("Total amout of sent by "))

    });

    it("...should not allow the employer to fund the contract with the too low of stake and payment amount", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new(10, 1, 1655609942, 1655869142, { from: accounts[0] });

        let amountFail = 9;

        //send stake and payment amount to contract
        try {
            await simpleContractInstance.setParticpantFunds({ from: accounts[0], amountFail })
            assert.fail("The transaction should have thrown an error");
        } catch (err) {
            assert.include(err.message, "Insufficent amount", "900 is below the stake and payment amount")
        }
    });
});

contract("Employee Fund", accounts => {
    it("...should allow the employee to fund the contract with the stake", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new(10, 1, 1655609942, 1655869142, { from: accounts[0] });

        await simpleContractInstance.setEmployee({ from: accounts[1] });

        let amountPass = 1; //gas cost

        //send stake and payment amount to contract
        await simpleContractInstance.setParticpantFunds({ from: accounts[1], value: amountPass })

        // Check Stake
        let particpant = await simpleContractInstance.particpants(accounts[1])
        assert.equal(particpant.hasStake, true, ("Stake should be set to true due to setParticpantFunds"))


        // Check employer sends correct amount
        assert.equal(particpant.stakeAmount, 1, ("Stake amount should be 10% of the payment amount"))
        assert.equal(particpant.totalAmount, 1, ("Total amout of sent by "))
    });

    it("...should not allow the employer to fund the contract with the too low of stake and payment amount", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new(10, 1, 1655609942, 1655869142, { from: accounts[0] });

        let amountFail = 0;

        await simpleContractInstance.setEmployee({ from: accounts[1] });

        //send stake and payment amount to contract
        try {
            await simpleContractInstance.setParticpantFunds({ from: accounts[1], value: amountFail })
            assert.fail("The transaction should have thrown an error");
        } catch (err) {
            assert.include(err.message, "Insufficent amount", "900 is below the stake and payment amount");
        }

    });

});*/

contract("Modify Date", accounts => {
    it("should allow state dates to be changed once both particpants have signed with same dates", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new(10000, 10, 1655609942, 1655869142, { from: accounts[0] });

        await simpleContractInstance.setEmployee({ from: accounts[1] });
        let _startDate = 1664659203;
        let _endDate = 1669929603;
        await simpleContractInstance.modifyDates(_startDate, _endDate, {
            from: accounts[0], gas: 5000000
        })
        await simpleContractInstance.modifyDates(_startDate, _endDate, { from: accounts[1], gas: 5000000 })
        const startDate = await simpleContractInstance.getStartDate()
        assert.equal(startDate, _startDate, "state start date should be updated now")
    });
}); 