// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

import "./ModifyDate.sol";

contract SimpleContractAgreement {
    address employer;
    address employee;
    uint256 maxEmployees = 1;
    uint256 startDate = 0;
    uint256 endDate = 0;
    uint256 tempStartDate = 0;
    uint256 tempEndDate = 0;
    uint256 employeeCounter = 0;
    uint256 paymentAmount = 0;
    bool employerDispute = false;
    uint256 stakeAmount = 0;
    uint256 contrtMonths = 0;
    event Received(address, uint256);
    event ModifyMismatch(uint256, uint256, uint256, uint256, string);

    constructor(
        uint256 _paymentAmount,
        uint256 _stakePercent,
        uint256 _contractMonths,
        uint256 _startDate,
        uint256 _endDate
    ) {
        require(_startDate < _endDate);
        employer = msg.sender;
        paymentAmount = _paymentAmount;
        stakeAmount = (_stakePercent / 100) * paymentAmount;
        contrtMonths = _contractMonths;
        startDate = _startDate;
        endDate = _endDate;
    }

    struct particpant {
        string particpantType;
        bool isStake;
        address particpantAddr;
        bool isEmployer;
        uint256 stakeAmount;
        uint256 totalAmount;
    }

    mapping(address => particpant) public particpants;
    mapping(address => bool) modifyContractDate;

    //give the option to the employer or employee to modify start and end date for the contract
    //requires signature of both parties
    function modifyDates(uint256 _start, uint256 _end) public onlyEmployer {
        require(
            _start < _end && (msg.sender == employee || msg.sender == employer)
        );
        require(!modifyContractDate[msg.sender]);
        uint256[2] memory _tempData = [_start, _end];
        address[2] memory _signatures = [employee, employer];
        ModifyDate date;
        if (date.modifyDates(_tempData, _signatures)) {
            startDate = _start;
            endDate = _end;
        } else {
            emit ModifyMismatch(
                tempStartDate,
                _start,
                tempEndDate,
                _end,
                "Dates do not match, signatures required again"
            );
        }
    }

    // withdraw function allows particpants to withdraw payment and stake for Employees
    // and stake for employers
    function withdraw(string memory _type)
        public
        payable
        particpantTypeAllowed(_type)
    {
        require(
            endDate != 0 &&
                block.timestamp >= endDate &&
                employerDispute == false
        );
        if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Employer")))
        ) {
            address payable receiver = payable(msg.sender);
            uint256 stake = particpants[msg.sender].stakeAmount;
            receiver.transfer(stake);
        }
        if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Employee")))
        ) {
            address payable receiver = payable(msg.sender);
            uint256 stake = particpants[msg.sender].stakeAmount;
            receiver.transfer(stake + paymentAmount);
        }
    }

    // if the contract hasnt started yet
    // if the contract start date has passed but only one participant
    // if the contract has started but one participant needs to withdraw from obligations
    function terminate(string memory _type) public {}

    // set the employer or employee and commit the stake amount to the contract. the employer also c
    // commits the payment amount to the contract.
    // You can only set particpant if the contract hasnt started yet
    function setParticpant(string memory _type)
        public
        payable
        particpantTypeAllowed(_type)
    {
        if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Employer")))
        ) {
            require(block.timestamp < startDate);
            require(
                msg.value == (stakeAmount + paymentAmount),
                "Insufficent transfer: Employer needs to send stake + payment amount"
            );
            emit Received(msg.sender, msg.value);
            particpants[msg.sender].particpantType = _type;
            particpants[msg.sender].isStake = true;
            particpants[msg.sender].particpantAddr = msg.sender;
            particpants[msg.sender].isEmployer = true;
            particpants[msg.sender].stakeAmount = msg.value - paymentAmount;
            particpants[msg.sender].totalAmount = msg.value;
        }
        if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Employee")))
        ) {
            require(block.timestamp < startDate);
            require(employeeCounter < 1);
            require(msg.value > stakeAmount, "Insufficent amount");
            emit Received(msg.sender, msg.value);
            particpants[msg.sender].particpantType = _type;
            particpants[msg.sender].isStake = true;
            particpants[msg.sender].particpantAddr = msg.sender;
            particpants[msg.sender].isEmployer = false;
            particpants[msg.sender].stakeAmount = stakeAmount;
            particpants[msg.sender].totalAmount = msg.value;

            employeeCounter += 1;
        }
    }

    function getPaymentAmountUSD() public view returns (uint256) {
        return paymentAmount;
    }

    function getEmployer() public view returns (address) {
        return employer;
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

    modifier particpantTypeAllowed(string memory _type) {
        require(
            keccak256(abi.encodePacked((_type))) ==
                keccak256(abi.encodePacked(("Employee"))) ||
                keccak256(abi.encodePacked((_type))) ==
                keccak256(abi.encodePacked(("Employer")))
        );
        _;
    }
}
