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
    bool particpantDispute = false;
    uint256 stakeAmount = 0;
    uint256 contrtMonths = 0;
    uint256 particpantID = 0;
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
        bool hasStake;
        address particpantAddr;
        bool isEmployer;
        uint256 stakeAmount;
        uint256 totalAmount;
    }

    address payable[] addresses;

    mapping(address => particpant) public particpants;

    //give the option to the employer or employee to modify start and end date for the contract
    //requires signature of both parties
    function modifyDates(uint256 _start, uint256 _end) public particpantsOnly {
        uint256[2] memory _tempData = [_start, _end];
        address[2] memory _signatures = [employee, employer];
        ModifyDate date;
        if (date.modifyDates(_tempData, _signatures)) {
            updateDates(_start, _end);
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

    function updateDates(uint256 _start, uint256 _end) private {
        startDate = _start;
        endDate = _end;
    }

    // withdraw function allows particpants to withdraw payment and stake for Employees
    // and stake for employers
    function withdraw() public payable particpantsOnly {
        require(
            endDate != 0 &&
                block.timestamp >= endDate &&
                particpantDispute == false
        );
        if (msg.sender == employer) {
            address payable receiver = payable(msg.sender);
            uint256 stake = particpants[msg.sender].stakeAmount;
            receiver.transfer(stake);
            resetParticpants(false);
        }
        if (msg.sender == employee) {
            address payable receiver = payable(msg.sender);
            uint256 stake = particpants[msg.sender].stakeAmount;
            receiver.transfer(stake + paymentAmount);
            resetParticpants(false);
        }
    }

    // if the contract hasnt started yet, send both back their stake
    // if the contract start date has passed but only one participant
    // if the contract has started but one participant needs to withdraw from obligations
    function terminate() public payable particpantsOnly {
        if (startDate < block.timestamp) {
            for (uint256 index = 0; index < addresses.length; index++) {
                address payable _receiver = addresses[index];
                uint256 _amount = particpants[msg.sender].totalAmount;
                _receiver.transfer(_amount);
            }
            resetParticpants(true);
        }
        if (
            (particpants[msg.sender].hasStake) && (startDate > block.timestamp)
        ) {
            address otherParticpant = getOtherParticpant();
            if (!particpants[otherParticpant].hasStake) {
                address payable _receiver = payable(msg.sender);
                uint256 _amount = particpants[msg.sender].totalAmount;
                _receiver.transfer(_amount);
            }
            resetParticpants(true);
        }
    }

    function getOtherParticpant() private view returns (address addr) {
        for (uint256 index = 0; index < addresses.length; index++) {
            if (addresses[index] != msg.sender) {
                return addresses[index];
            }
        }
    }

    function resetParticpants(bool _all) private {
        if (_all) {
            for (uint256 index = 0; index < addresses.length; index++) {
                particpants[addresses[index]].stakeAmount = 0;
                particpants[addresses[index]].totalAmount = 0;
                particpants[addresses[index]].hasStake = false;
            }
            addresses = new address payable[](0);
        } else {
            for (uint256 index = 0; index < addresses.length; index++) {
                if (addresses[index] == msg.sender) {
                    particpants[addresses[index]].stakeAmount = 0;
                    particpants[addresses[index]].totalAmount = 0;
                    particpants[addresses[index]].hasStake = false;
                }
            }
        }
    }

    // set the employer or employee and commit the stake amount to the contract. the employer also c
    // commits the payment amount to the contract.
    // You can only set particpant if the contract hasnt started yet
    function setParticpant(string memory _type) public payable particpantsOnly {
        if (msg.sender == employer) {
            require(block.timestamp < startDate);
            require(
                msg.value == (stakeAmount + paymentAmount),
                "Insufficent transfer: Employer needs to send stake + payment amount"
            );
            emit Received(msg.sender, msg.value);
            particpants[msg.sender].particpantType = _type;
            particpants[msg.sender].hasStake = true;
            particpants[msg.sender].particpantAddr = msg.sender;
            particpants[msg.sender].isEmployer = true;
            particpants[msg.sender].stakeAmount = msg.value - paymentAmount;
            particpants[msg.sender].totalAmount = msg.value;
            addresses[particpantID] = payable(msg.sender);
            particpantID += 1;
        }
        if (msg.sender == employee) {
            require(block.timestamp < startDate);
            require(employeeCounter < 1);
            require(msg.value > stakeAmount, "Insufficent amount");
            emit Received(msg.sender, msg.value);
            particpants[msg.sender].particpantType = _type;
            particpants[msg.sender].hasStake = true;
            particpants[msg.sender].particpantAddr = msg.sender;
            particpants[msg.sender].isEmployer = false;
            particpants[msg.sender].stakeAmount = stakeAmount;
            particpants[msg.sender].totalAmount = msg.value;
            addresses[particpantID] = payable(msg.sender);
            particpantID += 1;
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

    function setEmployee() public view notEmployer {
        require(block.timestamp < startDate);
        employee == msg.sender;
    }

    modifier onlyEmployer() {
        require(
            msg.sender == employer,
            "Only Employer allowed to call this function"
        );
        _;
    }

    modifier particpantsOnly() {
        require(msg.sender == employee || msg.sender == employer);
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
