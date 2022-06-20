// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

import "./AgreementAbstract.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

abstract contract ScheduledPaymentAgreement is AgreementAbstract {
    uint256 interval;
    uint256[] schedule;

    mapping(uint256 => bool) private paymentMade;

    function init(
        uint256 _paymentAmount,
        uint256 _stakeAmount,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _interval
    ) external {
        require(_startDate < _endDate && _startDate > block.timestamp);
        employer = payable(msg.sender);
        paymentAmount = _paymentAmount;
        stakeAmount = _stakeAmount;
        startDate = _startDate;
        endDate = _endDate;
        interval = _interval;
        schedule = calc();
        particpants[msg.sender].hasStake = false;
        particpants[msg.sender].particpantAddr = msg.sender;
        particpants[msg.sender].isEmployer = true;
    }

    // withdraw fun should allow user to withdraw scheuled portion of payment that is scheuled to be released.
    // you should only be able to draw down portion that is determined by the length of contract and the interval
    function withdrawEmployee() public payable onlyEmployee {
        require(particpantDispute == false);
        uint256 _timestamp;
        bool lastPayment = false;
        for (uint256 index = 0; index < schedule.length; index++) {
            if (block.timestamp > schedule[schedule.length - 1]) {
                _timestamp = schedule[schedule.length - 1];
                lastPayment = true;
            } else if (
                schedule[index] < block.timestamp &&
                schedule[index + 1] > block.timestamp
            ) {
                _timestamp = schedule[index];
            }
        }
        (bool success, uint256 result) = SafeMath.tryDiv(
            paymentAmount,
            interval
        );
        if (lastPayment) {
            require(paymentMade[_timestamp] == false);
            require(success);
            Address.sendValue(payable(employee), result);
            paymentMade[_timestamp] = true;
            super.resetParticpants(false);
        } else {
            require(paymentMade[_timestamp] == false);
            require(success);
            paymentMade[_timestamp] = true;
            Address.sendValue(payable(employee), result);
        }
    }

    // this should determine the schedules by returing an array of timestamps which should be if the internval was 4:
    // [next, next, next, end]
    // at the end of each section you can withdraw
    // if it is past the first section then, employee can withdraw and then map that timestamp
    function calc() private view returns (uint256[] memory _schedule) {
        uint256 diff = (endDate - startDate) / 60 / 60 / 24;
        uint256 intervalDays = diff / interval;
        uint256 timestamp = startDate;
        for (uint256 index = 0; index < interval; index += intervalDays) {
            timestamp += (intervalDays * 1 days);
            _schedule[index] = timestamp;
        }
    }

    function checkTimestamp() private view returns (uint256 _timestamp) {
        for (uint256 index = 0; index < schedule.length; index++) {
            if (block.timestamp > schedule[schedule.length - 1]) {
                return schedule[schedule.length - 1];
            } else if (
                schedule[index] < block.timestamp &&
                schedule[index + 1] > block.timestamp
            ) {
                return schedule[index];
            }
        }
    }
}
