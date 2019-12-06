from web3.auto import Web3

def start():
    project = ""
    student = ""
    date = 0
    axis = ""
    points = 0

    w3 = Web3(Web3.HTTPProvider("https://ropsten.infura.io/v3/123"))
    account = "0xD6bAb1D6d37608a2B15677c26881892Be1650B57"
    nonce = w3.eth.getTransactionCount(account)

    KorpusToken_Deposit = w3.eth.contract(
        address = "0x4a8274f4D0fD7F039B834C44Ed6B78258C09a1c3",
        abi = [ { "constant": "true", "inputs": [], "name": "name", "outputs": [ { "name": "", "type": "string" } ], "payable": "false", "stateMutability": "view", "type": "function" }, { "constant": "false", "inputs": [ { "name": "_spender", "type": "address" }, { "name": "_value", "type": "uint256" } ], "name": "approve", "outputs": [ { "name": "", "type": "bool" } ], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "constant": "true", "inputs": [], "name": "totalSupply", "outputs": [ { "name": "", "type": "uint256" } ], "payable": "false", "stateMutability": "view", "type": "function" }, { "constant": "false", "inputs": [ { "name": "newOwner", "type": "address" } ], "name": "transferOwnershipContract", "outputs": [], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "constant": "true", "inputs": [ { "name": "_project", "type": "string" }, { "name": "_date", "type": "uint256" }, { "name": "_student", "type": "string" }, { "name": "_axis", "type": "string" } ], "name": "studentResults", "outputs": [ { "name": "_result", "type": "uint256" } ], "payable": "false", "stateMutability": "view", "type": "function" }, { "constant": "false", "inputs": [ { "name": "_from", "type": "address" }, { "name": "_to", "type": "address" }, { "name": "_value", "type": "uint256" } ], "name": "transferFrom", "outputs": [ { "name": "", "type": "bool" } ], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "constant": "false", "inputs": [ { "name": "_to", "type": "address" }, { "name": "_amount", "type": "uint256" } ], "name": "mint", "outputs": [ { "name": "", "type": "bool" } ], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "constant": "false", "inputs": [ { "name": "_spender", "type": "address" }, { "name": "_subtractedValue", "type": "uint256" } ], "name": "decreaseApproval", "outputs": [ { "name": "success", "type": "bool" } ], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "constant": "true", "inputs": [ { "name": "_owner", "type": "address" } ], "name": "balanceOf", "outputs": [ { "name": "balance", "type": "uint256" } ], "payable": "false", "stateMutability": "view", "type": "function" }, { "constant": "false", "inputs": [ { "name": "burner", "type": "address" }, { "name": "_value", "type": "uint256" } ], "name": "burnFrom", "outputs": [], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "constant": "false", "inputs": [ { "name": "_project", "type": "string" }, { "name": "_student", "type": "string" }, { "name": "_date", "type": "uint256" }, { "name": "_axis", "type": "string" }, { "name": "_points", "type": "uint256" } ], "name": "addStudentResult", "outputs": [], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "constant": "true", "inputs": [], "name": "owner", "outputs": [ { "name": "", "type": "address" } ], "payable": "false", "stateMutability": "view", "type": "function" }, { "constant": "true", "inputs": [], "name": "symbol", "outputs": [ { "name": "", "type": "string" } ], "payable": "false", "stateMutability": "view", "type": "function" }, { "constant": "false", "inputs": [ { "name": "_to", "type": "address" }, { "name": "_value", "type": "uint256" } ], "name": "transfer", "outputs": [ { "name": "", "type": "bool" } ], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "constant": "true", "inputs": [], "name": "KorpusContract", "outputs": [ { "name": "", "type": "address" } ], "payable": "false", "stateMutability": "view", "type": "function" }, { "constant": "false", "inputs": [ { "name": "_spender", "type": "address" }, { "name": "_addedValue", "type": "uint256" } ], "name": "increaseApproval", "outputs": [ { "name": "success", "type": "bool" } ], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "constant": "true", "inputs": [ { "name": "_owner", "type": "address" }, { "name": "_spender", "type": "address" } ], "name": "allowance", "outputs": [ { "name": "remaining", "type": "uint256" } ], "payable": "false", "stateMutability": "view", "type": "function" }, { "constant": "false", "inputs": [ { "name": "newOwner", "type": "address" } ], "name": "transferOwnershipWallet", "outputs": [], "payable": "false", "stateMutability": "nonpayable", "type": "function" }, { "inputs": [], "payable": "false", "stateMutability": "nonpayable", "type": "constructor" }, { "anonymous": "false", "inputs": [ { "indexed": "true", "name": "from", "type": "address" }, { "indexed": "true", "name": "to", "type": "address" }, { "indexed": "false", "name": "value", "type": "uint256" } ], "name": "Transfer", "type": "event" }, { "anonymous": "false", "inputs": [ { "indexed": "true", "name": "owner", "type": "address" }, { "indexed": "true", "name": "spender", "type": "address" }, { "indexed": "false", "name": "value", "type": "uint256" } ], "name": "Approval", "type": "event" }, { "anonymous": "false", "inputs": [ { "indexed": "true", "name": "previousOwner", "type": "address" }, { "indexed": "true", "name": "newOwner", "type": "address" } ], "name": "OwnershipTransferred", "type": "event" } ]
)
    transaction = KorpusToken_Deposit.functions.addStudentResult(project, student, date, axis, points).buildTransaction(
            {
                'nonce': nonce,
                'from': account,
                'gas': 50000,
                'gasPrice': w3.toWei('3', 'gwei'),
                'chainId': 3
            }
        )

    private_key = ""
    signed_txn = w3.eth.account.signTransaction(transaction, private_key=private_key)
    txn_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    print(txn_hash.hex())