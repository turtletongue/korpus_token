// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

import "@openzeppelin/contracts@4.9.5/access/Ownable.sol";

contract whitelistBuyers is Ownable {
    mapping(address => bool) public buyers;
    mapping(address => uint256) public buyersLimits;

    event buyersAddressAdded(address addr);
    event buyersAddressRemoved(address addr);

    modifier onlyBuyers() {
        require(buyers[msg.sender]);
        _;
    }

    function addAddressToBuyers(address addr, uint256 limit)
        public
        onlyOwner
        returns (bool success)
    {
        if (limit >= 0) {
            buyers[addr] = true;
            buyersLimits[addr] = limit;
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
            buyersLimits[addr] = 0;
            emit buyersAddressRemoved(addr);
            success = true;
        }
    }
}
