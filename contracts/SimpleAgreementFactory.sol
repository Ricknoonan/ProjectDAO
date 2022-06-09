//SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

import "./CloneFactory.sol";
import "./SimpleContractAgreement.sol";

contract SimpleAgreementFactory is CloneFactory {
    SimpleContractAgreement[] public children;
    address masterContract;

    constructor(address _masterContract) {
        masterContract = _masterContract;
    }

    function createChild(
        uint256 _paymentAmount,
        uint256 _stakeAmount,
        uint256 _startDate,
        uint256 _endDate
    ) external {
        SimpleContractAgreement child = SimpleContractAgreement(
            createClone(masterContract)
        );
        child.init(_paymentAmount, _stakeAmount, _startDate, _endDate);
        children.push(child);
    }

    function getChildren()
        external
        view
        returns (SimpleContractAgreement[] memory)
    {
        return children;
    }
}
