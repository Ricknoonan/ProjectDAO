//SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

import "./CloneFactory.sol";
import "./ScheduledPaymentAgreement.sol";

contract ScheduledPaymentAgreementFactory is CloneFactory {
    ScheduledPaymentAgreement[] public children;
    address masterContract;

    constructor(address _masterContract) {
        masterContract = _masterContract;
    }

    function createChild(
        uint256 _paymentAmount,
        uint256 _stakeAmount,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _interval
    ) external {
        ScheduledPaymentAgreement child = ScheduledPaymentAgreement(
            createClone(masterContract)
        );
        child.init(
            _paymentAmount,
            _stakeAmount,
            _startDate,
            _endDate,
            _interval
        );
        children.push(child);
    }

    function getChildren()
        external
        view
        returns (ScheduledPaymentAgreement[] memory)
    {
        return children;
    }
}
