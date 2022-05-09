import React, { Component } from "react";
import SimpleContractAgreement from "./contracts/SimpleContractAgreement.json";
import getWeb3 from "./getWeb3";

import "./App.css";



class App extends Component {
  state = { web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();
      console.log(web3)
      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();
      console.log(accounts)
      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      console.log(networkId)
      const deployedNetwork = SimpleContractAgreement.networks[networkId];
      const instance = new web3.eth.Contract(
        SimpleContractAgreement.abi,
        deployedNetwork && deployedNetwork.address,
      );
      console.log(instance)
      console.log(SimpleContractAgreement.abi)

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance });
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };


  setEmployer = async () => {
    const { accounts, contract } = this.state;
    await contract.methods.setEmployer().send({ from: accounts[0] });
    const response = await contract.methods.getEmployer().call();
    this.setState({ employer: response });
  }

  setPaymentAmount = async () => {
    const { accounts, contract } = this.state;
    await contract.methods.setPaymentAmount(10000).send({ from: accounts[0] });
    const response = await contract.methods.getPaymentAmount().call();
    this.setState({ payment: response });
  }

  setContractMonths = async () => {
    const { accounts, contract } = this.state;
    await contract.methods.setContractMonths(2).send({ from: accounts[0] });
    const response = await contract.methods.getContractMonths().call();
    this.setState({ contractMonths: response });
  }

  setEmployee = async () => {
    const { accounts, contract } = this.state;
    await contract.methods.setEmployee().send({ from: accounts[0] });
    const response = await contract.methods.getEmployee().call();
    this.setState({ employee: response });
  }

  getEmployee = async () => {
    const { contract } = this.state;
    const response = await contract.methods.getEmployee().call();
    this.setState({ employee: response });
  }

  getEmployer = async () => {
    const { contract } = this.state;
    const response = await contract.methods.getEmployer().call();
    this.setState({ employer: response });
  }




  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (

      <div className="App">
        <h1>ProjectDAO</h1>
        <button onClick={this.setEmployer}>
          Set Employer
        </button>
        <button onClick={this.setPaymentAmount}>
          Set Payment
        </button>
        <button onClick={this.setContractMonths}>
          Set Contract Length
        </button>
        <button onClick={this.setEmployee}>
          Set Employee
        </button>
        <button onClick={this.getEmployee}>
          Get Employee
        </button>
        <button onClick={this.getEmployer}>
          Get Employer
        </button>
        <div>Employer: {this.state.employer}</div>
        <div>Payment: {this.state.payment}</div>
        <div>Contract Months: {this.state.contractMonths}</div>
        <div>Employee: {this.state.employee}</div>
      </div>
    );
  }
}

export default App;
