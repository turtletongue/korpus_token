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