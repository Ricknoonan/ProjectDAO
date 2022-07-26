// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <8.10.0;

contract SinglePaymentNoEndDate{

// payment is created
// employee starts work
// employee delivers service 
// employee submits a withdrawal request
// employer accepts or rejects
// each reject slashes the funded amount in the contract so that payment amount is reduced or the refund amount is reduced if the contract is terminated
// after three rejects, the contract is terminated
// emplyee withdraws
// employer gets money back if they both agree to terminate agreement 
// emplyee e

    //this logic handles the SR funding the contract 
    function fund() {
        
    }

    // this handles the SP trying to withdraw the funds
    function endContractRequest() {
        
    }

    function releaseFunds(){

    }

    //this handles the logic of the SP actually receiving the funds
    function withdraw() {
        
    }

    // this handles the SR giving approval
    function approveWithdraw(){

    }

    // this handles the SR rejecting the request
    function rejectWithdraw() {
        
    }


    // this handles the case where SP and SR mutually agree to termainte the contract and funds get returned to the SR
    function terminate() {
        
    }

}
