pub contract FanxToken {
    pub var totalSupply: UInt64;

    /*
        We are creating resource interfaces here, a resource will later be created named vault which will use all these interfaces to define methods and variables
    */

    pub resource interface Provider {
        pub fun withdraw(amount: UInt64): @Vault {
            post {
                // `result` refers to the return value of the function
                result.balance == UInt64(amount):
                    "Withdrawal amount must be the same as the balance of the withdrawn Vault"
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
        pub var balance: UInt64
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
            destroy from;
        }
    }

    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 0);
    }

    pub resource VaultMinter {
        pub fun mintTokens(amount: UInt64, recipient: Capability<&AnyResource{Receiver}>) {
            let recipientRef = recipient.borrow()
                ?? panic("Could not create a reference for the reciever to receive tokens")
            FanxToken.totalSupply = FanxToken.totalSupply + amount;
            recipientRef.deposit(from: <-create Vault(balance: amount));
        }
    }

    init() {
        self.totalSupply = 30;
        let vault <-create Vault(balance: self.totalSupply);
        self.account.save(<-vault, to: /storage/FanxTokensVault);
        self.account.save(<-create VaultMinter(), to: /storage/FnaxToeknsMinter)
        self.account.link<&VaultMinter>(/private/minter, target: /storage/FnaxToeknsMinter)
    }
}