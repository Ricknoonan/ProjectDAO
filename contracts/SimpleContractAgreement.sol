// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

contract SimpleContractAgreement {
    address employer;
    address employee;
    uint256 maxEmployees = 1;
    uint256 contractMonths;
    uint256 employerCounter;
    uint256 employeeCounter;
    int256 paymentAmount;

    function setContractMonths(uint256 months) public onlyEmployer {
        contractMonths = months;
    }

    function getContractMonths() public view returns (uint256) {
        return contractMonths;
    }

    function setPaymentAmount(int256 amount) public onlyEmployer {
        if (paymentAmount == 0) {
            paymentAmount = amount;
        }
    }

    function getPaymentAmount() public view returns (int256) {
        return paymentAmount;
    }

    function setEmployer() public notEmployee {
        if (employerCounter < 1) {
            employer = msg.sender;
            employerCounter++;
        }
    }

    function getEmployer() public view returns (address) {
        return employer;
    }

    function setEmployee() public notEmployer {
        if (employeeCounter < 1) {
            employee = msg.sender;
            employeeCounter++;
        }
    }

    function getEmployee() public view returns (address) {
        return employee;
    }

    modifier onlyEmployer() {
        require(
            msg.sender == employer,
            "Only Employer allowed to call this function"
        );
        _;
    }

    modifier notEmployer() {
        require(
            msg.sender != employer,
            "Employer not allowed to call this function"
        );
        _;
    }

    modifier notEmployee() {
        require(
            msg.sender != employee,
            "Employee not allowed to call this function"
        );
        _;
    }
}
