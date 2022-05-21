// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

import "./ModifyDate.sol";
import "./SimpleContractAgreementInterface.sol";

contract SimpleContractAgreement is SimpleContractAgreementInterface {
    address employer;
    address employee;
    uint256 startDate = 0;
    uint256 endDate = 0;
    uint256 public employeeCounter = 0;
    uint256 paymentAmount = 0;
    bool particpantDispute = false;
    uint256 public stakeAmount = 0;
    uint32 public stakePercent = 0;
    uint256 particpantID = 0;
    event Received(address, uint256);
    event ModifyMismatch(uint256, uint256, string);

    constructor(
        uint256 _paymentAmount,
        uint32 _stakePercent,
        uint256 _startDate,
        uint256 _endDate
    ) {
        require(_startDate < _endDate && _startDate > block.timestamp);
        employer = payable(msg.sender);
        paymentAmount = _paymentAmount;
        stakeAmount = ((_stakePercent / 100) * _paymentAmount);
        stakePercent = _stakePercent;
        startDate = _startDate;
        endDate = _endDate;
        particpants[msg.sender].hasStake = false;
        particpants[msg.sender].particpantAddr = msg.sender;
        particpants[msg.sender].isEmployer = true;
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

    function setEmployee() public notEmployer {
        require(block.timestamp < startDate);
        require(employeeCounter == 0);
        employee == msg.sender;
        employeeCounter += 1;
        particpants[msg.sender].hasStake = false;
        particpants[msg.sender].particpantAddr = msg.sender;
        particpants[msg.sender].isEmployer = false;
    }

    /*Condition: set the employer or employee and commit the stake amount to the contract. the employer also c
commits the payment amount to the contract.
You can only set particpant if the contract hasnt started yet
*/
    function setParticpantFunds() public payable particpantsOnly {
        if (msg.sender == employer) {
            require(block.timestamp < startDate);
            require(
                msg.value == (stakeAmount + paymentAmount),
                "Insufficent amount"
            );
            emit Received(msg.sender, msg.value);
            particpants[msg.sender].hasStake = true;
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
            particpants[msg.sender].hasStake = true;
            particpants[msg.sender].particpantAddr = msg.sender;
            particpants[msg.sender].isEmployer = false;
            particpants[msg.sender].stakeAmount = stakeAmount;
            particpants[msg.sender].totalAmount = msg.value;
            addresses[particpantID] = payable(msg.sender);
            particpantID += 1;
        }
    }

    /* Input: proposed start and end dates that they want to change to
Conditions:Give the option to the employer or employee to modify start and end date for the contract
requires signature of both parties
can only modify date if start date is in the future, start date is less than end date
and the initial start hasnt elapsed already
*/
    function modifyDates(uint256 _start, uint256 _end) public particpantsOnly {
        require(
            startDate > block.timestamp &&
                _start > block.timestamp &&
                _start < _end
        );
        uint256[2] memory _tempData = [_start, _end];
        address[2] memory _signatures = [employee, employer];
        ModifyDate date;
        if (date.modifyDates(_tempData, _signatures)) {
            updateDates(_start, _end);
        } else {
            emit ModifyMismatch(
                _start,
                _end,
                "Dates do not match, signatures required again"
            );
        }
    }

    function updateDates(uint256 _start, uint256 _end) private {
        startDate = _start;
        endDate = _end;
    }

    /* Condition: Sends money to both sender if the contract end date has passed and there isnt a dispute
withdraw function allows particpants to withdraw payment and stake for Employees
and stake for employers
 */

    function withdraw() public payable particpantsOnly {
        require(
            endDate != 0 &&
                block.timestamp >= endDate &&
                particpantDispute == false
        );
        if (msg.sender == employer) {
            uint256 stake = particpants[msg.sender].stakeAmount;
            payable(msg.sender).transfer(stake);
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

    function getPaymentAmount() public view returns (uint256) {
        return paymentAmount;
    }

    function getStakeAmount() public view returns (uint256) {
        return stakeAmount;
    }

    function getStakePercent() public view returns (uint32) {
        return stakePercent;
    }

    function getEmployeeCounter() public view returns (uint256) {
        return employeeCounter;
    }

    function getEmployer() public view returns (address) {
        return employer;
    }

    function getEmployee() public view returns (address) {
        return employee;
    }

    function getStartDate() public view returns (uint256) {
        return startDate;
    }

    function getEndDate() public view returns (uint256) {
        return endDate;
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
