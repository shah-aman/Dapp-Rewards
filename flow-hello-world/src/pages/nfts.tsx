import Head from 'next/head'
import "../flow/config";
import { useState, useEffect } from "react";
import * as fcl from "@onflow/fcl";
import { get } from 'https';

export default function Home() {

  const [user, setUser] = useState({loggedIn: null})
  const [name, setName] = useState('')
  let nftIds: number[] = [];
  let nftUrls: string[] = [];
  useEffect(() => fcl.currentUser.subscribe(setUser), [])

  // NEW
  const initAccount = async () => {
    const transactionId = await fcl.mutate({
      cadence: `
      import FanexNft from 0x3d1a73afefe2d7f8

      // This transaction configures a user's account
      // to use the NFT contract by creating a new empty collection,
      // storing it in their account storage, and publishing a capability
      transaction {
          prepare(acct: AuthAccount) {
      
              // Create a new empty collection
              let collection <- FanexNft.createEmptyCollection()
      
              // store the empty NFT Collection in account storage
              acct.save<@FanexNft.NFTCollection>(<-collection, to: FanexNft.CollectionStoragePath)
      
              log("Collection created for account 2")
      
              // create a public capability for the Collection
              acct.link<&{FanexNft.NFTReceiver}>(FanexNft.CollectionPublicPath, target: FanexNft.CollectionStoragePath)
      
              log("Capability created")
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
  const getNftIds = async () => {
    console.log(user.addr);
    const nfts = await fcl.query({
      cadence: `
      // Print All NFTs

      import FanexNft from 0x3d1a73afefe2d7f8
      
      // Print the NFTs owned by accounts 0x01 and 0x02.
      pub fun main(address: Address): [UInt64] {
      
          // Get both public account objects
          let account1 = getAccount(address)
      
          // Find the public Receiver capability for their Collections
          let acct1Capability = account1.getCapability(FanexNft.CollectionPublicPath)
      
          // borrow references from the capabilities
          let receiver1Ref = acct1Capability.borrow<&{FanexNft.NFTReceiver}>()
              ?? panic("Could not borrow account 1 receiver reference")
      
          // Print both collections as arrays of IDs
          log("Account 1 NFTs")
          log(receiver1Ref.getIDs())
          return receiver1Ref.getIDs();
      }
      `,
      args: (arg, t) => [arg(user.addr, t.Address)]
    })
    console.log(nfts);
    nftIds = nfts;
  }

  const getNftUrl = async (id: number) => {
    console.log(user.addr);
    const nft = await fcl.query({
      cadence: `
      // Print All NFTs

      import FanexNft from 0x3d1a73afefe2d7f8
      
      // Print the NFTs owned by accounts 0x01 and 0x02.
      pub fun main(address: Address, id: UInt64): String? {
      
          // Get both public account objects
          let account1 = getAccount(address)
      
          // Find the public Receiver capability for their Collections
          let acct1Capability = account1.getCapability(FanexNft.CollectionPublicPath)
      
          // borrow references from the capabilities
          let receiver1Ref = acct1Capability.borrow<&{FanexNft.NFTReceiver}>()
              ?? panic("Could not borrow account 1 receiver reference")
      
          // Print both collections as arrays of IDs
          log("Account 1 NFTs")
          log(receiver1Ref.getNftUrl(id: id))
          return receiver1Ref.getNftUrl(id: id)
      }
      `,
      args: (arg, t) => [arg(user.addr, t.Address), arg(id, t.UInt64)]
    }) as string
    return nft;
  }

  const withdrawNft = async () => {
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

  const mintNft = async () => {
    const transactionId = await fcl.mutate({
      cadence: `
      import FanexNft from 0x3d1a73afefe2d7f8
      import FanxToken from 0x3d1a73afefe2d7f8
      
      transaction(url: String, amount: UInt64) {
      
          let receiverRef: &{FanexNft.NFTReceiver}
      
          prepare(acct: AuthAccount) {
              self.receiverRef = acct.getCapability<&{FanexNft.NFTReceiver}>(FanexNft.CollectionPublicPath)
                  .borrow()
                  ?? panic("Could not borrow receiver reference")
      
              let newNFT <- FanexNft.mintNFT(url: url)
      
              self.receiverRef.deposit(token: <-newNFT)
              let vaultRef = acct.borrow<&FanxToken.Vault>(from: /storage/FanxTokenVault)
                  ?? panic("Could not borrow reference of owner\'s vault");
              let tempValut <- vaultRef.withdraw(amount: amount)
              destroy tempValut;
          }
      
          execute {
      
              // let tempVault <- vaultRef.withdraw(amount: amount);
              // destroy tempVault;
      
              log("NFT Minted and deposited to Account 1's Collection")
          }
      }
      `,
      args: (arg, t) => [arg("https://ibb.co/HX6y3Yc", t.String), arg(10, t.UInt64)],
      payer: fcl.authz,
      proposer: fcl.authz,
      authorizations: [fcl.authz],
      limit: 50
    });
    const transaction = await fcl.tx(transactionId).onceSealed()
    console.log(transaction)
  }

  const burnNft = async () => {
    const transactionId = await fcl.mutate({
        cadence: `
        import FanexNft from 0x3d1a73afefe2d7f8
        import FanxToken from 0x3d1a73afefe2d7f8
        
        transaction(id: UInt64, amount: UInt64) {
        
        
            prepare(acct: AuthAccount) {
                let receiverRef = acct.borrow<&{FanexNft.NFTBurner}>(from: FanexNft.CollectionStoragePath)
                    ?? panic("Could not borrow receiver reference")
                let deletedNft <- receiverRef.withdraw(withdrawID: id);
                destroy deletedNft;
                let tempVault <- FanxToken.createNonEmptyVault(balance: amount);
        
                let vaultRef = acct.borrow<&FanxToken.Vault>(from: /storage/FanxTokenVault)
                    ?? panic("Could not borrow reference of owner\'s vault");
                
                vaultRef.deposit(from: <-tempVault);
            }
        
            execute {
        
                log("NFT burned")
            }
        }
        `,
        args: (arg, t) => [arg(1, t.UInt64), arg(10, t.UInt64)],
        payer: fcl.authz,
        proposer: fcl.authz,
        authorizations: [fcl.authz],
        limit: 50
      });
      const transaction = await fcl.tx(transactionId).onceSealed()
      console.log(transaction)
  }

  const displayNfts = async () => {
    await getNftIds();
    for (const id of nftIds) {
        const url = await getNftUrl(id);
        console.log(url);
    }
  }

  const AuthedState = () => {
    return (
      <div>
        <div>Address: {user?.addr ?? "No Address"}</div>
        <div>Profile Name: {name ?? "--"}</div>
        {/* <button onClick={sendQuery}>Send Query</button> */}
        <button onClick={initAccount}>Init Account</button> {/* NEW */}
        <button onClick={mintNft}>Deposit NFT</button> {/* NEW */}
        <button onClick={displayNfts}>Get Nfts</button>
        <button onClick={burnNft}>Burn Nfts</button>
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
      <h1>Flow NFTS</h1>
      {user.loggedIn
        ? <AuthedState />
        : <UnauthenticatedState />
      }
    </div>
  )
}