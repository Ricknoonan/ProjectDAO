// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

contract SimpleContractAgreement {
    address employer;
    address employee;
    uint256 maxEmployees = 1;
    uint256 startDate = 0;
    uint256 endDate = 0;
    uint256 employeeCounter = 0;
    uint256 paymentAmount = 0;
    bool employerDispute = false;
    uint256 stakeAmount = 0;
    uint256 contrtMonths = 0;
    event Received(address, uint256);

    constructor(
        uint256 _paymentAmount,
        uint256 _stakePercent,
        uint256 _contractMonths
    ) {
        employer = msg.sender;
        paymentAmount = _paymentAmount;
        stakeAmount = (_stakePercent / 100) * paymentAmount;
        contrtMonths = _contractMonths;
    }

    struct particpant {
        string particpantType;
        bool isStake;
        address particpantAddr;
        bool isEmployer;
        uint256 stakeAmount;
        uint256 totalAmount;
    }

    mapping(address => particpant) public particpants;

    function setStartEndDate(uint256 start, uint256 end) public onlyEmployer {
        require(startDate < endDate);
        startDate = start;
        endDate = end;
    }

    // withdraw function allows particpants to withdraw payment and stake for Employees
    // and stake for employers
    function withdraw(string memory _type)
        public
        payable
        particpantTypeAllowed(_type)
    {
        require(
            endDate != 0 &&
                block.timestamp >= endDate &&
                employerDispute == false
        );
        if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Employer")))
        ) {
            address payable receiver = payable(msg.sender);
            uint256 stake = particpants[msg.sender].stakeAmount;
            receiver.transfer(stake);
        }
        if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Employee")))
        ) {
            address payable receiver = payable(msg.sender);
            uint256 stake = particpants[msg.sender].stakeAmount;
            receiver.transfer(stake + paymentAmount);
        }
    }

    function getPaymentAmountUSD() public view returns (uint256) {
        return paymentAmount;
    }

    function getEmployer() public view returns (address) {
        return employer;
    }

    // set the employer or employee and commit the stake amount to the contract. the employer also c
    // commits the payment amount to the contract.
    function setParticpant(string memory _type)
        public
        payable
        particpantTypeAllowed(_type)
    {
        if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Employer")))
        ) {
            require(block.timestamp < startDate);
            require(
                msg.value == (stakeAmount + paymentAmount),
                "Insufficent transfer: Employer needs to send stake + payment amount"
            );
            emit Received(msg.sender, msg.value);
            particpants[msg.sender].particpantType = _type;
            particpants[msg.sender].isStake = true;
            particpants[msg.sender].particpantAddr = msg.sender;
            particpants[msg.sender].isEmployer = true;
            particpants[msg.sender].stakeAmount = msg.value - paymentAmount;
            particpants[msg.sender].totalAmount = msg.value;
        }
        if (
            keccak256(abi.encodePacked((_type))) ==
            keccak256(abi.encodePacked(("Employee")))
        ) {
            require(block.timestamp < startDate);
            require(employeeCounter < 1);
            require(msg.value > stakeAmount, "Insufficent amount");
            emit Received(msg.sender, msg.value);
            particpants[msg.sender].particpantType = _type;
            particpants[msg.sender].isStake = true;
            particpants[msg.sender].particpantAddr = msg.sender;
            particpants[msg.sender].isEmployer = false;
            particpants[msg.sender].stakeAmount = stakeAmount;
            particpants[msg.sender].totalAmount = msg.value;

            employeeCounter += 1;
        }
    }

    function getEmployee() public view returns (address) {
        return employee;
    }

    modifier onlyEmployer() {
        require(
            msg.sender == employer,
            "Only Employer allowed to call this function"
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

    modifier particpantTypeAllowed(string memory _type) {
        require(
            keccak256(abi.encodePacked((_type))) ==
                keccak256(abi.encodePacked(("Employee"))) ||
                keccak256(abi.encodePacked((_type))) ==
                keccak256(abi.encodePacked(("Employer")))
        );
        _;
    }
}
