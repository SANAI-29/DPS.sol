from web3 import Web3
import json

w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))

if not w3.is_connected():
    print("not connected")
    
print("WE IN NETWORK!")
with open("blockchain/artifacts/contracts/Contract.sol/Contract.json") as f:
    config = json.load(f)



contract = w3.eth.contract(
    address=config["address"],
    abi=config["abi"]
)
