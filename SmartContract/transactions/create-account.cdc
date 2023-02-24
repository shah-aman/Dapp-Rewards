import FanxToken from 0x3d1a73afefe2d7f8

transaction {
    prepare(account: AuthAccount) {
        let vaultA <- FanxToken.createEmptyVault();

        account.save<@FanxToken.Vault>(<-vaultA, to: /storage/FanxTokenVault);

        // Deposit function exported
        let ReceiverRef = account.link<&FanxToken.Vault{FanxToken.Receiver}>(/public/FanxTokenReceiver, target: /storage/FanxTokenVault);

        let BalanceRef = account.link<&FanxToken.Vault{FanxToken.Balance}>(/public/FlowTokenBalance, target: /storage/FanxTokenBalance)

        log("References Created")
    }
}