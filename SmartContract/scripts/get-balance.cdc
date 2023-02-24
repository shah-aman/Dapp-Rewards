import FanxToken from 0x3d1a73afefe2d7f8

pub fun main(account: Address): UInt64 {
    let vaultRef = getAccount(account)
        .getCapability(/public/FlowTokenBalance)
        .borrow<&FanxToken.Vault{FanxToken.Balance}>()
        ?? panic("Could not borrow account reference to the vault")

    return vaultRef.balance
}