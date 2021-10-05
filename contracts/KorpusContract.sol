// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Импортируем библиотеку для контроля доступа.
// Она позволяет управлять ролями пользователей.
import "@openzeppelin/contracts/access/AccessControl.sol";

// Импортируем whitelist для покупателей токенов инвестиций.
import "./whitelistBuyers.sol";

// Импортируем whitelist для продавцов токенов вклада.
import "./whitelistSellers.sol";

// Объявляем интерфейс токена инвестиции.
interface KorpusToken_Investment {
    function transfer(address recipient, uint256 amount) external;

    function transferFrom(address sender, address recipient, uint256 amount) external;
    
    function balanceOf(address account) external view returns (uint256 balance);
}

// Объявляем интерфейс токена вклада.
interface KorpusToken_Deposit {
    function transfer(address recipient, uint256 amount) external;

    function transferFrom(address sender, address recipient, uint256 amount) external;
    
    function balanceOf(address account) external view returns (uint256 balance);
}

contract KorpusContract is AccessControl, whitelistBuyers, whitelistSellers {
    event TradeComplete(address trader, uint256 amount);

    KorpusToken_Investment _tokenI;
    KorpusToken_Deposit _tokenD;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Объявляем переменную для адреса текущего кошелька, способного обменивать токены.
    address _trader;

    // Объявляем переменную с лимитом токенов, которых можно обменивать.
    uint256 _exchangeLimit;

    // Объявляем переменную с ценой покупки токена инвестиций.
    uint256 _buyPriceKTI;

    // Объявляем переменную с ценой продажи токенов вклада.
    uint256 _sellPriceKTD;

    // Маппинг хранения информации о бюджете.
    // Дата -> Статья бюджета -> Количество потраченных денег.
    mapping(uint256 => mapping(string => uint256)) budget;

    constructor(KorpusToken_Investment tokenI, KorpusToken_Deposit tokenD) {
        _tokenI = tokenI;
        _tokenD = tokenD;
        // Данная роль позволяет устанавливать роли.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setTrader(address trader) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _trader = trader;
    }

    function getTrader() public view returns (address) {
        return _trader;
    }

    function setExchangeLimit(uint256 exchangeLimit) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _exchangeLimit = exchangeLimit;
    }

    function getExchangeLimit() public view returns (uint256) {
        return _exchangeLimit;
    }

    // Сеттер цены покупки токена инвестиций. (wei)
    function setBuyPriceKTI(uint256 buyPrice) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        // Проверяем корректность цены.
        require(buyPrice > 0);
        _buyPriceKTI = buyPrice;
    }

    // Геттер цены покупки токена инвестиций. (wei)
    function getBuyPriceKTI() public view returns (uint256) {
        return _buyPriceKTI;
    }

    // Сеттер цены продажи токена вклада. (wei)
    function setSellPriceKTD(uint256 sellPrice) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        // Проверяем корректность цены.
        require(sellPrice > 0);
        _sellPriceKTD = sellPrice;
    }

    // Геттер цены продажи токена вклада. (wei)
    function getSellPriceKTD() public view returns (uint256) {
        return _sellPriceKTD;
    }

    // Сеттер затрат по определенной статье бюджета.
    function setBudget(
        uint256 date,
        string memory budgetItem,
        uint256 cost
    ) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        budget[date][budgetItem] = cost;
    }

    // Геттер затрат по определенной статье бюджета.
    function getBudget(uint256 date, string memory budgetItem)
        public
        view
        returns (uint256)
    {
        return budget[date][budgetItem];
    }

    // Функция обмена токенов.
    function exchangeTokens(uint256 TKNbits) public {
        require(msg.sender == _trader, "You are not trader");
        
        require(TKNbits >= 0, "Amount must be greater or equeal to zero");

        require(TKNbits <= _exchangeLimit, "Exchange limit exceeded");
        
        require(_tokenD.balanceOf(address(this)) >= TKNbits, "Number of available tokens has been exceeded");
        
        require(_tokenI.balanceOf(msg.sender) >= TKNbits, "Not enough tokens on your account");
        
        _tokenI.transferFrom(msg.sender, address(this), TKNbits);
        
        _tokenD.transfer(msg.sender, TKNbits);

        _exchangeLimit = _exchangeLimit - TKNbits;

        emit TradeComplete(msg.sender, TKNbits);
    }

    // Внутренняя функция покупки токенов инвестиции.
    function _buy(address sender, uint256 amount) internal returns (uint256) {
        require(getBuyPriceKTI() > 0, "KTI buy price is not set");
        // Рассчитываем количество купленных токенов и приводим к TKNbits.
        uint256 TKNbits =
            (amount * 1000000000000000000) / getBuyPriceKTI();
            
        require(buyersLimits[sender] >= TKNbits, "Buy limit exceeded");

        _tokenI.transfer(sender, TKNbits);
        
        return TKNbits;
    }

    // Внешняя функция покупки токенов инвестиции.
    function buy() public payable onlyBuyers {
        _buy(msg.sender, msg.value);
    }

    // Функция обмена токенов вклада на wei.
    function sellKTD(uint256 TKNbits) public onlySellers {
        require(sellersLimits[msg.sender] >= TKNbits, "Seller limit exceeded");
        
        require(getSellPriceKTD() > 0);

        require(TKNbits >= 0);

        uint256 valueWEI = (TKNbits / 1000000000000000000) * getSellPriceKTD();
        
        require(address(this).balance >= valueWEI, "Number of WEI in contract exceeded");

        _tokenD.transferFrom(msg.sender, address(this), TKNbits);
        // Отправляем wei на кошелёк получателя.
        payable(msg.sender).transfer(valueWEI);
    }

    // Функция отправки на адрес wei со смарт-контракта.
    function transferWEI(address payable receiver, uint256 numberOfWei) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        // Отправляем получателю wei.
        receiver.transfer(numberOfWei);
    }
}
