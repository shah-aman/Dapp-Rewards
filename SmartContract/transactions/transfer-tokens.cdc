import FanxToken from 0x3d1a73afefe2d7f8

transaction(amount: UInt64, to: Address) {
    let sentVault: @FanxToken.Vault;

    prepare(signer: AuthAccount) {
        let vaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/FanxTokenVault)
            ?? panic("Could not borrow reference of owner\'s vault");
        
        self.sentVault <- vaultRef.withdraw(amount: amount);
    }

    execute {
        let receiverRef = getAccount(to)
            .getCapability(/public/FanxTokenReceiver)
            .borrow<&FanxToken.Receiver>()
        
        receiverRef.deposit(from: <-self.sentVault)
    }
}