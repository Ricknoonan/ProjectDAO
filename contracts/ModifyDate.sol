// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

// have they both signed and does the data match

//TODO refactor  modify date out so that the multi sig function is refactored out
contract ModifyDate {
    uint256[] modifyTempArr;

    mapping(address => bool) modifyContractDate;

    /*
Input : the proposed dates from one of the parties and the list of sigs required
Conditions: If the sender is the first party to sign then mark the temps as their proposal, otherwise
compare the proposal dates with the temps to see if they match. Resets temps if not a match
Returns: true if the proposal and the temps match
*/
    function modifyDates(
        uint256[2] memory _tempDate,
        address[2] memory _signatures
    ) public returns (bool success) {
        require(!modifyContractDate[msg.sender]);
        modifyContractDate[msg.sender] = true;
        if (modifyTempArr[0] == 0 && modifyTempArr[1] == 0) {
            modifyTempArr[0] = _tempDate[0];
            modifyTempArr[1] = _tempDate[1];
        } else {
            require(
                modifyContractDate[_signatures[0]] &&
                    modifyContractDate[_signatures[1]]
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
}
