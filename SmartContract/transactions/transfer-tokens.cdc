import FanxToken from 0x3d1a73afefe2d7f8

transaction(amount: UInt64, address: Address) {
    let tokenSender: @FanxToken.Vault;
    let tokenReceiver: &{FanxToken.Receiver}

    prepare(account: AuthAccount) {
        let vaultRef = account.borrow<&FanxToken.Vault>(from: /storage/FanxTokenVault)
            ?? panic("Could not borrow reference of owner\'s vault") 
        self.tokenSender <- vaultRef.withdraw(amount: amount);
        self.tokenReceiver = getAccount(address)
        .getCapability(/public/FanxTokenReceiver)
        .borrow<&{FanxToken.Receiver}>()
            ?? panic("Unable to borrow receiver")
    }

    execute {        
        self.tokenReceiver.deposit(from: <-self.tokenSender)
    }
}
