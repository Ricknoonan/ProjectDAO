// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

import "./SimpleContractAgreementInterface.sol";

abstract contract SimpleContractAgreement is SimpleContractAgreementInterface {
    address employer;
    address employee;
    uint256 startDate = 0;
    uint256 endDate = 0;
    uint256 employeeCounter = 0;
    uint256 paymentAmount = 0;
    bool particpantDispute = false;
    uint256 stakeAmount = 0;
    uint32 stakePercent = 0;
    uint256 particpantID = 0;
    event Received(address, uint256);
    event ModifyMismatch(uint256, uint256, string);
    event Log(string);
    uint256[] modifyTempArr;

    struct particpant {
        uint256 id;
        string particpantType;
        bool hasStake;
        address particpantAddr;
        bool isEmployer;
        uint256 stakeAmount;
        uint256 totalAmount;
    }

    address payable[] addresses;

    mapping(address => particpant) public particpants;

    mapping(address => bool) modifyContractDate;

    /*This functions allows employees to "apply" and set themseleves as employee in
     * the contract without actually commiting funds
     */
    function setOnlyEmployee() public notEmployer {
        require(block.timestamp < startDate);
        require(employeeCounter == 0);
        employee = msg.sender;
        employeeCounter += 1;
        particpants[msg.sender].hasStake = false;
        particpants[msg.sender].particpantAddr = msg.sender;
        particpants[msg.sender].isEmployer = false;
    }

    /*Condition: set the employer or employee and commit the stake amount to the contract. the employer also c
     * commits the payment amount to the contract.
     * You can only set particpant if the contract hasnt started yet
     */
    function setParticpantFunds() public payable particpantsOnly {
        if (msg.sender == employer) {
            require(block.timestamp < startDate, "must be before start date");
            require(
                msg.value >= (stakeAmount + paymentAmount),
                "Insufficent amount"
            );
            emit Received(msg.sender, msg.value);
            particpants[msg.sender].hasStake = true;
            particpants[msg.sender].stakeAmount = stakeAmount;
            particpants[msg.sender].totalAmount = msg.value;
            particpants[msg.sender].id = particpantID;
            addresses.push(payable(msg.sender));
            particpantID += 1;
        }
        if (msg.sender == employee) {
            require(block.timestamp < startDate);
            require(msg.value >= stakeAmount, "Insufficent amount");
            emit Received(msg.sender, msg.value);
            particpants[msg.sender].hasStake = true;
            particpants[msg.sender].id = particpantID;
            particpants[msg.sender].stakeAmount = stakeAmount;
            particpants[msg.sender].totalAmount = msg.value;
            addresses.push(payable(msg.sender));
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
                _start < _end,
            "Invalid Time"
        );
        uint256[2] memory _tempDates;
        address[2] memory _tempSig;
        _tempDates = [_start, _end];
        _tempSig = [employee, employer];
        if (modifyDate(_tempDates, _tempSig)) {
            startDate = _start;
            endDate = _end;
        } else {
            emit ModifyMismatch(
                _start,
                _end,
                "Dates do not match, signatures required again"
            );
        }
    }

    function modifyDate(
        uint256[2] memory _tempDate,
        address[2] memory _signatures
    ) private returns (bool success) {
        require(
            modifyContractDate[msg.sender] == false,
            "Address has already signed"
        );
        modifyContractDate[msg.sender] = true;
        if (modifyTempArr.length == 0) {
            modifyTempArr.push(_tempDate[0]);
            modifyTempArr.push(_tempDate[1]);
        } else {
            require(
                modifyContractDate[_signatures[0]] &&
                    modifyContractDate[_signatures[1]],
                "Need signatures from both parties"
            );
            if (
                modifyTempArr[0] == _tempDate[0] &&
                modifyTempArr[1] == _tempDate[1]
            ) {
                return success = true;
            } else {
                modifyContractDate[_signatures[0]] = false;
                modifyContractDate[_signatures[1]] = false;
                modifyTempArr[0] = 0;
                modifyTempArr[1] = 0;
                return success = false;
            }
        }
    }

    function getOtherParticpant() internal view returns (address addr) {
        for (uint256 index = 0; index < addresses.length; index++) {
            if (addresses[index] != msg.sender) {
                return addresses[index];
            }
        }
    }

    function resetParticpants(bool _all) internal {
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

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    modifier onlyEmployer() {
        require(
            msg.sender == employer,
            "Only Employer allowed to call this function"
        );
        _;
    }

    modifier particpantsOnly() {
        require(
            msg.sender == employee || msg.sender == employer,
            "Particpants Only"
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
