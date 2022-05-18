pragma solidity >=0.4.21 <8.10.0;

interface SimpleContractAgreementInterface {
    function modifyDates(uint256 _start, uint256 _end) external;

    function withdraw() external payable;

    function terminate() external payable;

    function setParticpant(string memory _type) external payable;
}
