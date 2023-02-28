import Head from 'next/head'
import "../flow/config";
import { useState, useEffect } from "react";
import * as fcl from "@onflow/fcl";
import { get } from 'https';

export default function Home() {

  const [user, setUser] = useState({loggedIn: null})
  const [name, setName] = useState('')

  useEffect(() => fcl.currentUser.subscribe(setUser), [])

  // NEW
  const initAccount = async () => {
    const transactionId = await fcl.mutate({
      cadence: `
      import FanxToken from 0x3d1a73afefe2d7f8

      transaction {
          prepare(account: AuthAccount) {
              let vaultA <- FanxToken.createEmptyVault();
      
              account.save<@FanxToken.Vault>(<-vaultA, to: /storage/FanxTokenVault);
      
              // Deposit function exported
              let ReceiverRef = account.link<&FanxToken.Vault{FanxToken.Receiver}>(/public/FanxTokenReceiver, target: /storage/FanxTokenVault);
      
              let BalanceRef = account.link<&FanxToken.Vault{FanxToken.Balance}>(/public/FanxTokenBalance, target: /storage/FanxTokenVault)
      
              log("References Created")
          }
      }
      `,
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 50
    })
    
    const transaction = await fcl.tx(transactionId).onceSealed()
    console.log(transaction)
  }
  const getBalance = async () => {
    console.log(user.addr);
    const balance = await fcl.query({
      cadence: `
      import FanxToken from 0x3d1a73afefe2d7f8

      pub fun main(account: Address): UInt64 {
          let vaultRef = getAccount(account)
              .getCapability(/public/FanxTokenBalance)
              .borrow<&FanxToken.Vault{FanxToken.Balance}>()
              ?? panic("Could not borrow account reference to the vault")
      
          return vaultRef.balance
      }
      `,
      args: (arg, t) => [arg(user.addr, t.Address)]
    })
    console.log(balance);
  }

  const depositMoney = async () => {
    const transactionId = await fcl.mutate({
      cadence: `
      import FanxToken from 0x3d1a73afefe2d7f8

      transaction(amount: UInt64) {
          prepare(account: AuthAccount) {
              let tempVault <- FanxToken.createNonEmptyVault(balance: amount);
      
              let vaultRef = account.borrow<&FanxToken.Vault>(from: /storage/FanxTokenVault)
                  ?? panic("Could not borrow reference of owner\'s vault");
              
              vaultRef.deposit(from: <-tempVault);
      
              log("Tokens despoited in account")
          }
      }   
      `,
      args: (arg, t) => [arg(10, t.UInt64)],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 50
    })
    
    const transaction = await fcl.tx(transactionId).onceSealed()
    console.log(transaction)
  }

  const withdrawMoney = async () => {
    const transactionId = await fcl.mutate({
      cadence: `
      import FanxToken from 0x3d1a73afefe2d7f8

      transaction(amount: UInt64) {
          prepare(account: AuthAccount) {
      
              let vaultRef = account.borrow<&FanxToken.Vault>(from: /storage/FanxTokenVault)
                  ?? panic("Could not borrow reference of owner\'s vault");
              
              let tempVault <- vaultRef.withdraw(amount: amount);
              destroy tempVault;
              log("Tokens despoited in account")
          }
      }
      
      `,
      args: (arg, t) => [arg(10, t.UInt64)],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 50
    });
    const transaction = await fcl.tx(transactionId).onceSealed()
    console.log(transaction)
  }

  const addTokenToAnyAccount =  async () => {
    const transactionId = await fcl.mutate({
      cadence: `
      import FanxToken from 0x3d1a73afefe2d7f8

      transaction(amount: UInt64, address: Address) {
          let tokenReceiver: &{FanxToken.Receiver}
      
          prepare(account: AuthAccount) {
              self.tokenReceiver = getAccount(address)
              .getCapability(/public/FanxTokenReceiver)
              .borrow<&{FanxToken.Receiver}>()
                  ?? panic("Unable to borrow receiver")
          }
      
          execute {
              let tempVault <- FanxToken.createNonEmptyVault(balance: amount);
              self.tokenReceiver.deposit(from: <-tempVault);
          }
      }
       
      `,
      args: (arg, t) => [arg(25, t.UInt64), arg("0x18242b040b7d7253", t.Address)],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 50
    });
    const transaction = await fcl.tx(transactionId).onceSealed()
    console.log(transaction)
  }; 

  const AuthedState = () => {
    return (
      <div>
        <div>Address: {user?.addr ?? "No Address"}</div>
        <div>Profile Name: {name ?? "--"}</div>
        {/* <button onClick={sendQuery}>Send Query</button> */}
        <button onClick={initAccount}>Init Account</button> {/* NEW */}
        <button onClick={getBalance}>Get Balance</button> {/* NEW */}
        <button onClick={depositMoney}>Deposit</button> {/* NEW */}
        <button onClick={withdrawMoney}>Withdraw</button> {/* NEW */}
        <button onClick={addTokenToAnyAccount}>Add to any account</button> NEW
        <button onClick={fcl.unauthenticate}>Log Out</button>
      </div>
    )
  }

  const UnauthenticatedState = () => {
    return (
      <div>
        <button onClick={fcl.logIn}>Log In</button>
        <button onClick={fcl.signUp}>Sign Up</button>
      </div>
    )
  }

  return (
    <div>
      <Head>
        <title>FCL Quickstart with NextJS</title>
        <meta name="description" content="My first web3 app on Flow!" />
        <link rel="icon" href="/favicon.png" />
      </Head>
      <h1>Flow App</h1>
      {user.loggedIn
        ? <AuthedState />
        : <UnauthenticatedState />
      }
    </div>
  )
}