import FanxToken from 0x3d1a73afefe2d7f8

transaction(amount: UInt64) {
    prepare(account: AuthAccount) {

        let vaultRef = account.borrow<&FanxToken.Vault>(from: /storage/FanxTokenVault)
            ?? panic("Could not borrow reference of owner\'s vault");
        
        let tempVault <- vaultRef.withdraw(amount: amount);
        destroy tempVault;
        log("Tokens despoited in account")
    }
}
