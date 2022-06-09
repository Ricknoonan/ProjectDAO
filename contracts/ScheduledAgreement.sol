// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

import "./SimpleContractAgreement.sol";

contract ScheduledAgreemnet is SimpleContractAgreement {
    string interval;

    function init(
        uint256 _paymentAmount,
        uint256 _stakeAmount,
        uint256 _startDate,
        uint256 _endDate,
        string memory _interval
    ) external {
        require(_startDate < _endDate && _startDate > block.timestamp);
        employer = payable(msg.sender);
        paymentAmount = _paymentAmount;
        stakeAmount = _stakeAmount;
        startDate = _startDate;
        endDate = _endDate;
        interval = _interval;
        particpants[msg.sender].hasStake = false;
        particpants[msg.sender].particpantAddr = msg.sender;
        particpants[msg.sender].isEmployer = true;
    }
}
