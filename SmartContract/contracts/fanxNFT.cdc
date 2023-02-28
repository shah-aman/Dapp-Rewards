pub contract FanexNft {
    pub var idCount: UInt64;

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    pub resource NFT {
        pub let id: UInt64;
        pub let url: String;

        init (id: UInt64, url: String) {
            self.id = id;
            self.url = url;
        }
    } 

    pub resource interface NFTReceiver {

        pub fun deposit(token: @NFT)

        pub fun getIDs(): [UInt64]

        pub fun idExists(id: UInt64): Bool

        pub fun getNftUrl(id: UInt64): String?
    }

    pub resource interface NFTBurner {
        pub fun withdraw(withdrawID: UInt64): @NFT;
    }

    pub resource NFTCollection: NFTReceiver, NFTBurner {
        pub var ownedNFTs: @{UInt64: NFT}

        init () {
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NFT {
            // If the NFT isn't found, the transaction panics and reverts
            let token <- self.ownedNFTs.remove(key: withdrawID)
                ?? panic("Cannot withdraw the specified NFT ID")

            return <-token
        }

        pub fun deposit(token: @NFT) {
            // add the new token to the dictionary with a force assignment
            // if there is already a value at that key, it will fail and revert
            self.ownedNFTs[token.id] <-! token
        }

        pub fun idExists(id: UInt64): Bool {
            return self.ownedNFTs[id] != nil
        }

        pub fun getNftUrl(id: UInt64): String? {
            return self.ownedNFTs[id]?.url;
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @NFTCollection {
        return <- create NFTCollection()
    }

    pub fun mintNFT(url: String): @NFT {

        // create a new NFT
        var newNFT <- create NFT(id: self.idCount, url: url)

        // change the id so that each ID is unique
        self.idCount = self.idCount + 1

        return <-newNFT
    }

	init() {
        self.CollectionStoragePath = /storage/nftTutorialCollection
        self.CollectionPublicPath = /public/nftTutorialCollection
        self.MinterStoragePath = /storage/nftTutorialMinter
        // initialize the ID count to one
        self.idCount = 1

        // store an empty NFT Collection in account storage
        self.account.save(<-self.createEmptyCollection(), to: self.CollectionStoragePath)

        // publish a reference to the Collection in storage
        self.account.link<&{NFTReceiver}>(self.CollectionPublicPath, target: self.CollectionStoragePath)
        self.account.link<&{NFTBurner}>(/private/nftTutorialCollection, target: self.CollectionStoragePath)
	}
}