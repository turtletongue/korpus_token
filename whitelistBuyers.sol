pragma solidity ^0.4.24;

import "https://github.com/PlatonSterh/korpus_token/Ownable.sol";

contract whitelistBuyers is Ownable {
    mapping(address => bool) public buyers;

    event buyersAddressAdded(address addr);
    event buyersAddressRemoved(address addr);

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlyBuyers() {
        require(buyers[msg.sender]);
        _;
    }


    /**
     * @dev add an address to the whitelist
     * @param addr address
     * @return true if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToBuyers(address addr) onlyOwner public returns(bool success) {
        if (!buyers[addr]) {
            buyers[addr] = true;
            emit buyersAddressAdded(addr);
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     * @return true if at least one address was added to the whitelist,
     * false if all addresses were already in the whitelist
     */
    function addAddressesToBuyers(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToBuyers(addrs[i])) {
                success = true;
            }
        }
    }

    /**
     * @dev remove an address from the whitelist
     * @param addr address
     * @return true if the address was removed from the whitelist,
     * false if the address wasn't in the whitelist in the first place
     */
    function removeAddressFromBuyers(address addr) onlyOwner public returns(bool success) {
        if (buyers[addr]) {
            buyers[addr] = false;
            emit buyersAddressRemoved(addr);
            success = true;
        }
    }

    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     * @return true if at least one address was removed from the whitelist,
     * false if all addresses weren't in the whitelist in the first place
     */
    function removeAddressesFromBuyers(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromBuyers(addrs[i])) {
                success = true;
            }
        }
    }

}
//.