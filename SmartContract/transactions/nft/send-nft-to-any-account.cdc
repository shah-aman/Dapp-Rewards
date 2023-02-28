import FanexNft from 0x3d1a73afefe2d7f8

// This transaction allows the Minter account to mint an NFT
// and deposit it into its collection.

transaction(address: Address, url: String) {

    // The reference to the collection that will be receiving the NFT
    let receiverRef: &{FanexNft.NFTReceiver}

    prepare(acct: AuthAccount) {
        // Get the owner's collection capability and borrow a reference
        self.receiverRef = getAccount(address).getCapability<&{FanexNft.NFTReceiver}>(FanexNft.CollectionPublicPath)
            .borrow()
            ?? panic("Could not borrow receiver reference")
    }

    execute {
        // Use the minter reference to mint an NFT, which deposits
        // the NFT into the collection that is sent as a parameter.
        let newNFT <- FanexNft.mintNFT(url: url)

        self.receiverRef.deposit(token: <-newNFT)

        log("NFT Minted and deposited to Account 1's Collection")
    }
}