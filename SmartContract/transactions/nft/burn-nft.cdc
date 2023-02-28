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