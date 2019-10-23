// Указываем версию языка для компилятора.
pragma solidity ^0.4.24;

import "https://github.com/PlatonSterh/korpus_token/Ownable.sol";
import "https://github.com/PlatonSterh/korpus_token/whitelistBuyers.sol";
import "https://github.com/PlatonSterh/korpus_token/whitelistSellers.sol";
import "https://github.com/PlatonSterh/korpus_token/SafeMath.sol";

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

// Объявляем контракт обмена, покупки и продажи токенов.
contract KorpusContract is Ownable, whitelistBuyers, whitelistSellers {
    
    // Подключаем библиотеку SafeMath.
    using SafeMath for uint256;

    // Объявляем ивент о обмене токенов.
    event tradeComplete(address trader);
    // Объявляем ивент о продаже токенов.
    event sold(address _buyer);

    // Объявлем переменные токенов.
    KorpusToken_Investment tokenI;
    KorpusToken_Deposit tokenD;
     
    // Объявляем переменную с адресом, обладающим правами обмена токенов.
    address public trader;
    // Объявляем переменную с лимитом обмениваемых токенов.
    uint public exchangeLimit;
    // Объявляем переменную с ценой токена инвестиций.
    uint public buyPrice;
    // Объявляем переменную с ценой продажи токена вклада.
    uint public sellPrice;

    // Двойной маппинг для хранения информации о бюджете Корпуса.
    mapping(uint256 => mapping(string => uint256)) budget;
    
    // Функция для определения бюджета Корпуса.
    function setBudget(uint256 _date, string memory _budgetItem, uint256 _cost) public onlyOwner {
        budget[_date][_budgetItem] = _cost;
    }
    
        // Функция, показывающая затраты Корпуса.
    function budgetInformation(uint256 _date, string memory _budgetItem) public view returns (uint256 _result) {
        // Возвращаем затраты по определённой оси.
        return budget[_date][_budgetItem];
    }

    /** Конструктор задаёт адреса токенов в переменные.
     * @param _tokenI токен инвестиций.
     * @param _tokenD токен вклада.
    */
    constructor(KorpusToken_Investment _tokenI, KorpusToken_Deposit _tokenD) public {
        // Присваиваем значения переменным токенов.
        tokenI = _tokenI;
        tokenD = _tokenD;
    }
    
    // Функция присваивания адреса, который может обменивать токены.
    function setTrader(address _trader) public onlyOwner {
       trader = _trader;
    }
    
    // Функция присваивания значения переменной лимита токенов инвестий, при обмене.
    function setExchangeLimit(uint _limit) public onlyOwner {
        exchangeLimit = _limit;
    }
    
    //  Функция присваивания цены продажи токенов инвестиций.
    function setBuyPrice(uint _buyPrice) public onlyOwner {
        buyPrice = _buyPrice;
    }
    
    // Функция присваивания количества Wei, на который можно обменять токен вклада.
    function setSellPriceKTD(uint _sellPriceKTD) public onlyOwner {
        sellPrice = _sellPriceKTD;
    }

    // Функция обмена токенов инвестиций на токены вклада.
    function exchangeTokens(uint _value) public {
        // Проверяем, что отправитель запроса обладает правом на обмен токенов.
        require(msg.sender == trader);
        // Проверяем, что не привышен лимит.
        require(_value <= exchangeLimit);
        // Сжигамем токены инвестиций с адреса.
        tokenI.burnFrom(msg.sender, _value);
        // Создаём на адресе получателя токены вклада.
        tokenD.mint(msg.sender, _value);
        // Ивентируем обмен.
        emit tradeComplete(msg.sender);
        // Вычитаем из лимита число токенов, которое уже обменяли.
        exchangeLimit = exchangeLimit.sub(_value);
    }

    // Внешняя функция покупки токенов инвестиций.
    function buy() public payable onlyBuyers {
        // Вызываем внутреннюю функцию покупки токенов инвестиции.
        _buy(msg.sender, msg.value);
    }

    // Внутренняя функция покупки токенов инвестиций.
    function _buy(address _sender, uint256 _amount) internal returns (uint) {
        // Проверяем, что пользователь покупает как минимум один токен.
        require(_amount >= buyPrice);
        // Рассчитываем стоимость.
        uint tokens = _amount.div(buyPrice);
        // Создаём токены инвестиций на адресе отправителя.
        tokenI.mint(_sender, tokens);
        // Возвращаем значение.
        return tokens;
        // Ивентируем покупку токенов.
        emit sold(msg.sender);
    }
    
    // Функция обмена токенов вклада на wei.
    function sellKTD(uint _value) public onlySellers {
        Проверяем, что указано верное количество токенов.
        require(_value >= 0);
        // Проверяем, установлена ли цена продажи токена.
        assert(sellPrice >= 0);
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