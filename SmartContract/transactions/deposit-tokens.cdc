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
