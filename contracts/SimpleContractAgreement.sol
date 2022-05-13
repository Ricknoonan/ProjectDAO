// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

contract SimpleContractAgreement {
    address employer;
    address employee;
    uint256 maxEmployees = 1;
    uint256 startDate = 0;
    uint256 endDate = 0;
    uint256 employerCounter = 0;
    uint256 employeeCounter = 0;
    uint256 paymentAmount = 0;
    bool employerDispute = false;
    event Received(address, uint256);

    function setStartEndDate(uint256 start, uint256 end) public onlyEmployer {
        require(startDate < endDate);
        startDate = start;
        endDate = end;
    }

    function withdrawPayment() public payable onlyEmployee {
        require(
            endDate != 0 &&
                block.timestamp >= endDate &&
                employerDispute == false
        );
        address payable receiver = payable(msg.sender);
        receiver.transfer(paymentAmount);
    }

    receive() external payable onlyEmployer {
        require(paymentAmount == 0 && block.timestamp < startDate);
        paymentAmount = msg.value;
        emit Received(msg.sender, msg.value);
    }

    function getPaymentAmountUSD() public view returns (uint256) {
        return paymentAmount;
    }

    function setEmployer() public notEmployee {
        require(employerCounter < 1);
        employer = msg.sender;
        employerCounter++;
    }

    function getEmployer() public view returns (address) {
        return employer;
    }

    function setEmployee() public notEmployer {
        require(employerCounter > 0 && employeeCounter < 1);
        employee = msg.sender;
        employeeCounter++;
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

    modifier onlyEmployee() {
        require(
            msg.sender == employee,
            "Only Employee allowed to call this function"
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
