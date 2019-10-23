pragma solidity ^0.4.24;

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    /**
     * Конструктор Ownable задаёт владельца контракта с помощью аккаунта отправителя.
     */
    constructor() public {
        owner = msg.sender;
    }
    /**
     * Выбрасывает ошибку, если вызвана любым аккаунтом, кроме владельца или бота.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    /**
     * Позволяет текущему владельцу перевести контроль над контрактом новому владельцу.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}