// Указываем версию языка для компилятора.
pragma solidity ^0.4.24;

// Объявляем интерфейс токена инвестиции.
interface KorpusToken_Investment {
    function mint(address _to, uint256 _amount) external;
    function burnFrom(address burner, uint256 _amount) external;
}

// Объявляем интерфейс токена вклада.
interface KorpusToken_Deposit {
    function mint(address _to, uint256 _amount) external;
    function burnFrom(address burner, uint256 _amount) external;
}

// Библиотека для защиты от переполнения uint.
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

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

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
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

contract whitelistSellers is Ownable {
    
    mapping(address => bool) public sellers;

    event sellersAddressAdded(address addr);
    event sellersAddressRemoved(address addr);

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlySellers() {
        require(sellers[msg.sender]);
        _;
    }

    /**
     * @dev add an address to the whitelist
     * @param addr address
     * @return true if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToSellers(address addr) onlyOwner public returns(bool success) {
        if (!sellers[addr]) {
            sellers[addr] = true;
            emit sellersAddressAdded(addr);
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist
     * @param addrs addresses
     * @return true if at least one address was added to the whitelist,
     * false if all addresses were already in the whitelist
     */
    function addAddressesToSellers(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToSellers(addrs[i])) {
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
    function removeAddressFromSellers(address addr) onlyOwner public returns(bool success) {
        if (sellers[addr]) {
            sellers[addr] = false;
            emit sellersAddressRemoved(addr);
            success = true;
        }
    }

    /**
     * @dev remove addresses from the whitelist
     * @param addrs addresses
     * @return true if at least one address was removed from the whitelist,
     * false if all addresses weren't in the whitelist in the first place
     */
    function removeAddressesFromSellers(address[] addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromSellers(addrs[i])) {
                success = true;
            }
        }
    }

}

// Объявляем контракт обмена, покупки и продажи токенов.
contract KorpusContract is whitelistBuyers, whitelistSellers {
    
    // Подключаем библиотеку SafeMath.
    using SafeMath for uint256;

    // Объявляем ивент об обмене токенов.
    event tradeComplete(address trader);
    // Объявляем ивент о продаже токенов.
    event sold(address _buyer);

    // Объявлем переменные токенов.
    KorpusToken_Investment tokenI;
    KorpusToken_Deposit tokenD;
     
    // Объявляем переменную с адресом для обмена.
    address public trader;
    // Объявляем переменную с лимитом для обмена.
    uint public tradeLimit;
    // Объявляем переменную с ценой токена.
    uint public buyPrice;
    // Объявляем переменную с ценой обмена токенов.
    uint public sellPrice;

    //Двойной маппинг для хранения информации о бюджете.
    mapping(uint256 => mapping(string => uint256)) budget;
    
    function setBudget(uint256 _date, string memory _budgetItem, uint256 _cost) public onlyOwner {
        budget[_date][_budgetItem] = _cost;
    }
    
        // Функция, показывающая количество баллов студента по определённой оси.
    function budgetInformation(uint256 _date, string memory _budgetItem) public view returns (uint256 _result) {
        // Возвращаем затраты по определённой оси.
        return budget[_date][_budgetItem];
    }

    /** Конструктор задаёт адреса токенов в переменные.
     * @param _tokenI токен инвестиций.
     * @param _tokenD токен вклада.
    */
    constructor(KorpusToken_Investment _tokenI, KorpusToken_Deposit _tokenD) public {
        // Присваиваем токены
        tokenI = _tokenI;
        tokenD = _tokenD;
    }
    
    // Функция присваивания адреса, который может обменивать токены.
    function setTrader(address _trader) public onlyOwner {
       trader = _trader;
    }
    
    // Функция присваивания значения переменной лимита токенов инвестий при обмене.
    function setTradeLimit(uint _limit) public onlyOwner {
        tradeLimit = _limit;
    }
    
    //  Функция присваивания цены продажи токенов.
    function setBuyPrice(uint _buyPrice) public onlyOwner {
        buyPrice = _buyPrice;
    }
    
    // Функция присваивания количества вей, на который можно обменять токен вклада.
    function setSellPriceTV(uint _sellPriceTV) public onlyOwner {
        sellPrice = _sellPriceTV;
    }

    // Функция обмена токенов.
    function trade(uint _value) public {
        // Проверяем, что функцию вызвал нужный адрес.
        require(msg.sender == trader);
        // Проверяем, что не привышен лимит.
        require(_value <= tradeLimit);
        // Сжигамем токены инвестиции с адреса.
        tokenI.burnFrom(msg.sender, _value);
        // Переводим на адрес токены вклада со смарт-контракта.
        tokenD.mint(msg.sender, _value);
        // Ивентируем обмен.
        emit tradeComplete(msg.sender);
        // Вычитаем из лимита число обмениваемых токенов.
        tradeLimit = tradeLimit.sub(_value);
    }

    // Внешняя функция покупки токенов инвестиции.
    function buy() public payable onlyBuyers {
        // Вызываем внутреннюю функцию покупки токенов инвестиции.
        _buy(msg.sender, msg.value);
    }

    // Внутренняя функция покупки токенов инвестиции.
    function _buy(address _sender, uint256 _amount) internal returns (uint){
        // Проверяем, что пользователь покупает как минимум один токен.
        require(_amount >= buyPrice);
        // Рассчитываем стоимость.
        uint tokens = _amount.div(buyPrice);
        // Отправляем токены с помощью вызова метода токена.
        tokenI.mint(_sender, tokens);
        // Возвращаем значение.
        return tokens;
        // Ивентируем продажу токенов.
        emit sold(msg.sender);
    }
    
    // Функция обмена токенов вклада на wei.
    function sellTokensV(uint _value) public onlySellers {
        // Проверяем, установлена ли цена продажи токена.
        assert(sellPrice != 0);
        // Вычисляем стоимость продаваемых токенов в wei.
        uint valueWEI = _value.mul(sellPrice);
        // Сжигаем токены вклада с адреса.
        tokenD.burnFrom(msg.sender, _value);
        // Отправляем wei на кошелёк получателя.
        msg.sender.transfer(valueWEI);
    }
    
    // Функция отправки на адрес вей со смарт-контракта.
    function transferWEI(address _receiver, uint _wei) public onlyOwner {
        // Присваиваем адрес получателя.
        address receiver = _receiver;
        // Отправляем получателю wei.
        receiver.transfer(_wei);
    }
}