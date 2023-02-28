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