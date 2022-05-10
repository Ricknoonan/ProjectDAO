const SimpleContractAgreement = artifacts.require("./SimpleContractAgreement.sol");

contract("SimpleContractAgreement", accounts => {
    it("...should set Employer as the first account", async () => {
        const simpleContractInstance = await SimpleContractAgreement.deployed();

        // Set Employer address
        await simpleContractInstance.setEmployer({
            from: "0x7148c46e9103405b057E94191e1C1FFAfA7425E3"
        });

        // Get Employer address
        const address = await simpleContractInstance.getEmployer.call();

        assert.equal(address, "0x7148c46e9103405b057E94191e1C1FFAfA7425E3", "Employer is now the first account");
    });
});

contract("SimpleContractAgreement", accounts => {
    it("...set employee with employer add then with new addr", async () => {
        const simpleContractInstance = await SimpleContractAgreement.deployed();

        // Set Employee address
        await simpleContractInstance.setEmployee.send({ from: accounts[0] });

        const employeeAddress1 = await simpleContractInstance.getEmployee.call();


        assert.equal(employeeAddress1, "0x0000000000000000000000000000000000000000", "The Employee is stil the default address");
        await simpleContractInstance.setEmployee.send({ from: accounts[1] });


        // Get Employer address
        const address = await simpleContractInstance.getEmployee.call();

        assert.equal(address, accounts[1], "The Employee is stil stored");
    });
});