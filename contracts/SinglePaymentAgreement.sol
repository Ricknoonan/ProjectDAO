// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

import "./SimpleContractAgreement.sol";

contract SimplePaymentAgreSimpleement is SimpleContractAgreement {
    function init(
        uint256 _paymentAmount,
        uint256 _stakeAmount,
        uint256 _startDate,
        uint256 _endDate
    ) external {
        require(_startDate < _endDate && _startDate > block.timestamp);
        employer = payable(msg.sender);
        paymentAmount = _paymentAmount;
        stakeAmount = _stakeAmount;
        startDate = _startDate;
        endDate = _endDate;
        particpants[msg.sender].hasStake = false;
        particpants[msg.sender].particpantAddr = msg.sender;
        particpants[msg.sender].isEmployer = true;
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
            super.resetParticpants(false);
        }
        if (msg.sender == employee) {
            address payable receiver = payable(msg.sender);
            uint256 stake = particpants[msg.sender].stakeAmount;
            receiver.transfer(stake + paymentAmount);
            super.resetParticpants(false);
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
            super.resetParticpants(true);
        }
        if (
            (particpants[msg.sender].hasStake) && (startDate > block.timestamp)
        ) {
            address otherParticpant = super.getOtherParticpant();
            if (!particpants[otherParticpant].hasStake) {
                address payable _receiver = payable(msg.sender);
                uint256 _amount = particpants[msg.sender].totalAmount;
                _receiver.transfer(_amount);
            }
            super.resetParticpants(true);
        }
    }
}
