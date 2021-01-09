// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract whitelistBuyers is Ownable {
    mapping(address => bool) public buyers;

    event buyersAddressAdded(address addr);
    event buyersAddressRemoved(address addr);

    modifier onlyBuyers() {
        require(buyers[msg.sender]);
        _;
    }

    function addAddressToBuyers(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (!buyers[addr]) {
            buyers[addr] = true;
            emit buyersAddressAdded(addr);
            success = true;
        }
    }

    function removeAddressFromBuyers(address addr)
        public
        onlyOwner
        returns (bool success)
    {
        if (buyers[addr]) {
            buyers[addr] = false;
            emit buyersAddressRemoved(addr);
            success = true;
        }
    }
}
