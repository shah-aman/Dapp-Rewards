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