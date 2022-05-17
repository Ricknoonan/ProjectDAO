// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

// have they both signed and does the data match
contract ModifyDate {
    uint256[] modifyTempArr;

    mapping(address => bool) modifyContractDate;

    function modifyDates(
        uint256[2] memory _tempDate,
        address[2] memory signatures
    ) public returns (bool success) {
        require(!modifyContractDate[msg.sender]);
        modifyContractDate[msg.sender] = true;
        if (modifyTempArr[0] == 0 && modifyTempArr[1] == 0) {
            modifyTempArr[0] = _tempDate[0];
            modifyTempArr[1] = _tempDate[1];
        } else {
            require(
                modifyContractDate[signatures[0]] &&
                    modifyContractDate[signatures[1]]
            );
            if (
                modifyTempArr[0] == _tempDate[0] &&
                modifyTempArr[1] == _tempDate[1]
            ) {
                return success = true;
            } else {
                modifyContractDate[signatures[0]] = false;
                modifyContractDate[signatures[1]] = false;
                modifyTempArr[0] = 0;
                modifyTempArr[1] = 0;
                return success = false;
            }
        }
    }
}
