import FanxToken from 0x3d1a73afefe2d7f8

pub fun main(address: Address): Bool {
    let vaultRef = getAccount(address)
        .getCapability<&FanxToken.Vault{FanxToken.Balance}>(/public/FanxTokenBalance)
        .check()

    return vaultRef
}
