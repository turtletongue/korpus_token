// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract whitelistSellers is Ownable {
    mapping(address => bool) public sellers;

    event sellersAddressAdded(address addr);
    event sellersAddressRemoved(address addr);

    modifier onlySellers() {
        require(sellers[msg.sender]);
        _;
    }

    function addAddressToSellers(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (!sellers[addr]) {
            sellers[addr] = true;
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
            emit sellersAddressRemoved(addr);
            success = true;
        }
    }
}
