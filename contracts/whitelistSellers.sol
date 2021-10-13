// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <=0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract whitelistSellers is Ownable {
    mapping(address => bool) public sellers;
    mapping(address => uint256) public sellersLimits;

    event sellersAddressAdded(address addr);
    event sellersAddressRemoved(address addr);

    modifier onlySellers() {
        require(sellers[msg.sender]);
        _;
    }

    function addAddressToSellers(address addr, uint256 limit)
        public
        onlyOwner
        returns (bool success)
    {
        if (limit >= 0) {
            sellers[addr] = true;
            sellersLimits[addr] = limit;
            emit sellersAddressAdded(addr);
            success = true;
        }
    }

    function removeAddressFromSellers(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (sellers[addr]) {
            sellers[addr] = false;
            sellersLimits[addr] = 0;
            emit sellersAddressRemoved(addr);
            success = true;
        }
    }
    
    function isInSellers(address addr) public view returns (bool isSeller) {
        return sellers[addr];
    }
}
