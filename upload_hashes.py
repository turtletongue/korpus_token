

from web3.auto import Web3
import requests
import time

def block():
    w3 = Web3(Web3.HTTPProvider("https://ropsten.infura.io/v3/123"))
    botAccount = "0x0"
    receiver = "0x0"
    q = requests.get('https://elvote.ru/php/get_hash.php')
    open_hash = q.text

    nonce = w3.eth.getTransactionCount(botAccount, 'pending')

    test_txn = {
        'from': botAccount,
        'to': receiver,
        'chainId': 3,
        'gas': 25000,
        'gasPrice': w3.toWei('1', 'gwei'),
        'nonce': nonce,
        'data': "0x0"
    }
    private_key = "123"
    signed_txn = w3.eth.account.signTransaction(test_txn, private_key=private_key)
    txn_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
    ether_hash = txn_hash.hex()
    hashes = {'ohash': open_hash, 'ehash': ether_hash} 
    r = requests.post('https://elvote.ru/php/get_hash.php', data = hashes)