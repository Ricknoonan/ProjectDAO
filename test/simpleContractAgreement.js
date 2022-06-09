const SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol");

contract("Employee", accounts => {
    it("...should set the employee", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new({ from: accounts[0] });
        simpleContractInstance.init(10, 1, 1655609942, 1655869142, { from: accounts[0] })
        await simpleContractInstance.setOnlyEmployee({ from: accounts[1] });

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
        const simpleContractInstance = await SimpleContractAgreement.new({ from: accounts[0] });
        simpleContractInstance.init(10, 1, 1655609942, 1655869142, { from: accounts[0] })
        let amountPass = 11;

        await simpleContractInstance.setOnlyEmployee({ from: accounts[1] });

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
        const simpleContractInstance = await SimpleContractAgreement.new({ from: accounts[0] });
        simpleContractInstance.init(10, 1, 1655609942, 1655869142, { from: accounts[0] })
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
        const simpleContractInstance = await SimpleContractAgreement.new({ from: accounts[0] });
        simpleContractInstance.init(10, 1, 1655609942, 1655869142, { from: accounts[0] })
        await simpleContractInstance.setOnlyEmployee({ from: accounts[1] });

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
        const simpleContractInstance = await SimpleContractAgreement.new({ from: accounts[0] });
        simpleContractInstance.init(10, 1, 1655609942, 1655869142, { from: accounts[0] })
        let amountFail = 0;

        await simpleContractInstance.setOnlyEmployee({ from: accounts[1] });

        //send stake and payment amount to contract
        try {
            await simpleContractInstance.setParticpantFunds({ from: accounts[1], value: amountFail })
            assert.fail("The transaction should have thrown an error");
        } catch (err) {
            assert.include(err.message, "Insufficent amount", "900 is below the stake and payment amount");
        }

    });

});

contract("Modify Date", accounts => {
    it("should allow state dates to be changed once both particpants have signed with same dates", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new({ from: accounts[0] });
        simpleContractInstance.init(10, 1, 1655609942, 1655869142, { from: accounts[0] })

        await simpleContractInstance.setOnlyEmployee({ from: accounts[1] });
        let _startDate = 1664659205;
        let _endDate = 1669929603;
        await simpleContractInstance.modifyDates(_startDate, _endDate, {
            from: accounts[0], gas: 5000000
        })
        await simpleContractInstance.modifyDates(_startDate, _endDate, { from: accounts[1], gas: 5000000 })
        const startDate = await simpleContractInstance.getStartDate()
        const endDate = await simpleContractInstance.getEndDate()
        assert.equal(startDate, _startDate, "state start date should be updated to new date")
        assert.equal(endDate, _endDate, "state end date should be updated to new date")

    });

    it("should allow state dates to be changed once both particpants have signed with same dates", async () => {
        const simpleContractInstance = await SimpleContractAgreement.new({ from: accounts[0] });
        simpleContractInstance.init(10, 1, 1655609942, 1655869142, { from: accounts[0] })

        await simpleContractInstance.setOnlyEmployee({ from: accounts[1] });
        let _startDate1 = 1664659205;
        let _endDate1 = 1669929603;
        await simpleContractInstance.modifyDates(_startDate1, _endDate1, {
            from: accounts[0], gas: 5000000
        })
        let _startDate2 = 16646592123;
        let _endDate2 = 16699296123;
        await simpleContractInstance.modifyDates(_startDate2, _endDate2, { from: accounts[1], gas: 5000000 })
        const startDate = await simpleContractInstance.getStartDate()
        assert.notEqual(startDate, _startDate1, "state start date should not be updated as they dont match")
        const endDate = await simpleContractInstance.getEndDate()
        assert.notEqual(endDate, _endDate1, "state start date should be updated as they dont match")
    });
}); 