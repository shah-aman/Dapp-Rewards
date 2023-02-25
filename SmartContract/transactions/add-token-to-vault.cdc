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
 