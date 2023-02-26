
from app.airdrop.models import AirDropAudit
import subprocess
from datetime import datetime

db_data = {
    "collection": "airdrop"
}

flow_cmd = """flow transactions send /Users/livspace/Documents/web3/Dapp-Rewards/SmartContract/transactions/add-token-to-vault.cdc {no_of_token} {wallet_address} --authorizer "my-testnet-account" --gas-limit 50 --payer "my-testnet-account" --proposer "my-testnet-account" -n testnet -f /Users/livspace/Documents/web3/Dapp-Rewards/backend/fanex-admin-app/flow.json"""

class AirDropService:
    def audit_airdrop(self, data):
        audit = AirDropAudit().create({"Document":data})
        print('audit log:', audit)
        return

    def run_flow_cmd(self, flow_cmd):
        """
        add token to wallet
        cmd to run flow API from cli
        """
        print('start flow cmd: ', datetime.now())
        p1 = subprocess.run([flow_cmd], shell=True)
        print('end flow cmd: ', datetime.now())

        print(p1)

    def assign_token_to_wallet(self, request_data):

        wallet_address = request_data["wallet_address"]
        no_of_token = request_data["no_of_token"]


        # audit log
        self.audit_airdrop(request_data)

        flow_cmd_modified = flow_cmd.format(no_of_token=no_of_token, wallet_address=wallet_address)

        # call SDK
        self.run_flow_cmd(flow_cmd_modified)

        return "ok"
