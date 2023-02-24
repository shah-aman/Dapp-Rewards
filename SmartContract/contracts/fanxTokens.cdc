pub contract FanxToken {
    pub var totalSupply: UInt64;

    pub resource interface Provider {
        pub fun withdraw(amount: UInt64): @Vault {
            post {
                result.balance == UInt64(amount):
                "Withdraw balance should be same as balance of withrwoan amount"
            }
        }
    }

    pub resource interface Receiver {
        pub fun deposit(from: @Vault) {
            pre {
                from.balance > 0:
                "Deposit balance must be positive"
            }
        }        
    }

    pub resource interface Balance {
        pub var balance: UInt64;
    }


    pub resource Vault: Receiver, Provider, Balance {
        pub var balance: UInt64;

        init(balance: UInt64) {
            self.balance = balance;
        }

        pub fun withdraw(amount: UInt64): @Vault {
            self.balance = self.balance - amount;
            return <-create Vault(balance: amount);
        }

        pub fun deposit(from: @Vault) {
            self.balance = self.balance + from.balance;
            destroy  from; 
        }
    }

    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 10)
    }

    pub resource VaultMinter {
        pub fun mintTokens(amount: UInt64, recipient: Capability<&AnyResource{Receiver}>) {
            let recipientRef = recipient.borrow()
                ?? panic("Could not borrow reciever reference to the vault")
            FanxToken.totalSupply = FanxToken.totalSupply + amount;
            recipientRef.deposit(from: <-create Vault(balance: amount));
        }
    }

    init() {
        self.totalSupply = 1000000;
        let vault <-create Vault(balance: self.totalSupply);
        self.account.save(<-vault, to:/storage/FanxTokenVault)

        self.account.save(<-create VaultMinter(), to: /storage FanxTokenMinter);
        self.account.link<&VaultMinter>(/private/Minter, target: /storage/FanxTokenMinter);
    }
}
