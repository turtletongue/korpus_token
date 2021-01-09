// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

// Импортируем библиотеку для контроля доступа.
// Она позволяет управлять ролями пользователей.
import "@openzeppelin/contracts/access/AccessControl.sol";

// Импортируем библиотеку, защищающую числа от переполнения.
import "@openzeppelin/contracts/math/SafeMath.sol";

// Импортируем whitelist для покупателей токенов инвестиций.
import "./whitelistBuyers.sol";

// Импортируем whitelist для продавцов токенов вклада.
import "./whitelistSellers.sol";

// Объявляем интерфейс токена инвестиции.
interface KorpusToken_Investment {
    function mint(address to, uint256 amount) external;

    function burnFrom(address burner, uint256 amount) external;
}

// Объявляем интерфейс токена вклада.
interface KorpusToken_Deposit {
    function mint(address to, uint256 amount) external;

    function burnFrom(address burner, uint256 amount) external;
}

contract KorpusContract is AccessControl, whitelistBuyers, whitelistSellers {
    // Защищаем числа от переполнения.
    using SafeMath for uint256;

    // Объявляем ивент обмена токенов.
    event tradeComplete(address trader, uint256 amount);

    KorpusToken_Investment _tokenI;
    KorpusToken_Deposit _tokenD;

    // Создаём роль для бота.
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
        // Уставливаем роль администратора создателю токенов.
        // Данная роль позволяет устанавливать роли.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Сеттер адреса, который может обменивать токены.
    function setTrader(address trader) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _trader = trader;
    }

    // Геттер адреса, который может обменивать токены.
    function getTrader() public view returns (address) {
        return _trader;
    }

    // Сеттер лимита токенов инвестиции при обмене.
    function setExchangeLimit(uint256 exchangeLimit) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _exchangeLimit = exchangeLimit;
    }

    // Геттер лимита токенов инвестиции при обмене.
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
        // Проверяем, что вызвавший функцию адрес обладает необходимыми правами.
        require(msg.sender == _trader);
        // Проверяем, что число не меньше нуля.
        require(TKNbits >= 0);
        // Проверяем, что не превышен лимит обмена.
        require(TKNbits <= _exchangeLimit);
        // Сжигамем токены инвестиции с адреса.
        _tokenI.burnFrom(msg.sender, TKNbits);
        // Создаем на адресе пользователя токены вклада.
        _tokenD.mint(msg.sender, TKNbits);
        // Вычитаем из лимита число токенов, которое уже обменяли.
        _exchangeLimit = _exchangeLimit.sub(TKNbits);
        // Ивентируем обмен.
        emit tradeComplete(msg.sender, TKNbits);
    }

    // Внутренняя функция покупки токенов инвестиции.
    function _buy(address sender, uint256 amount) internal returns (uint256) {
        // Рассчитываем количество купленных токенов и приводим к TKNbits.
        uint256 TKNbits =
            (amount.mul(1000000000000000000)).div(getBuyPriceKTI());
        // Создаем токены инвестиции на адресе пользователя.
        _tokenI.mint(sender, TKNbits);
        // Возвращаем количество купленных токенов.
        return TKNbits;
    }

    // Внешняя функция покупки токенов инвестиции.
    function buy() public payable onlyBuyers {
        // Вызываем внутреннюю функцию покупки токенов инвестиции.
        _buy(msg.sender, msg.value);
    }

    // Функция обмена токенов вклада на wei.
    function sellKTD(uint256 TKNbits) public onlySellers {
        // Проверяем, установлена ли цена продажи токена.
        require(getSellPriceKTD() > 0);
        // Проверяем, что число не меньше нуля.
        require(TKNbits >= 0);
        // Вычисляем стоимость продаваемых токенов в wei.
        uint256 valueWEI = (TKNbits.div(1000000000000000000)).mul(getSellPriceKTD());
        // Сжигаем токены вклада с адреса.
        _tokenD.burnFrom(msg.sender, TKNbits);
        // Отправляем wei на кошелёк получателя.
        msg.sender.transfer(valueWEI);
    }

    // Функция отправки на адрес wei со смарт-контракта.
    function transferWEI(address payable receiver, uint256 numberOfWei) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        // Отправляем получателю wei.
        receiver.transfer(numberOfWei);
    }
}
