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