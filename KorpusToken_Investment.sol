pragma solidity ^0.5.1;

import "https://github.com/PlatonSterh/korpus_token/Ownable.sol";
import "https://github.com/PlatonSterh/korpus_token/SafeMath.sol";

contract KorpusToken_Investment is Ownable {
    
    // Переменная с числом выпущенных и существующих токенов.
    uint256 public totalSupply;
    
    // Ивент перевода токенов на другой адрес.
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // Подключаем библиотку SafeMath.
    using SafeMath for uint256;
    // Маппинг балансов пользователей.
    mapping(address => uint256) balances;

    // Функция перевода токенов на другой адрес.
    function transfer(address _to, uint256 _value) public returns (bool) {
        // Проверка на пустой адрес.
        require(_to != address(0));
        // Проверяем, что у пользователя достаточно токенов для перевода.
        require(_value <= balances[msg.sender]);
        // Убираем с баланса оптравителя токены.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        // Добавляем получателю на баланс токены.
        balances[_to] = balances[_to].add(_value);
        // Ивентируем перевод.
        emit Transfer(msg.sender, _to, _value);
        // Возращает true, если перевод удался.
        return true;
    }
    
    // Функция, показывающее баланс пользователя, через адрес.
    function balanceOf(address _owner) public view returns (uint256 balance) {
        // Возращает пользователю баланс.
        return balances[_owner];
    }
    
    // Маппинг, позволюящий разрешить использовать токены с кошелька другому адресу.
    mapping (address => mapping (address => uint256)) internal allowed;
    // Ивент о разрешении использования токенов.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Функция перевода токенов с одного адреса на другой. Не обязательно, чтобы переводимые токены были на адресе отправителя.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        // Проверка на пустой адрес.
        require(_to != address(0));
        // Проверка на наличие переводимых токенов у адреса, с которого они переводятся.
        require(_value <= balances[_from]);
        // Проверка на то, что пользователь может использовать эти токены в переводе, имеет право их переводить.
        require(_value <= allowed[_from][msg.sender]);
        // Токены списываются с адреса.
        balances[_from] = balances[_from].sub(_value);
        // Токены начисляются на адрес получателя.
        balances[_to] = balances[_to].add(_value);
        // Забираем право распоряжаться этим количеством токена у адреса оптравителя.
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        // Ивентируем перевод.
        emit Transfer(_from, _to, _value);
        // Возращает true, если перевод удался.
        return true;
    }

    // Функция, показывающая количество токенов, разрешённых определённым кошельком другому адресу.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        // Возвращаем количство разрешённых токенов.
        return allowed[_owner][_spender];
    }
    
    // Функция, разрешающая использовать некоторое количество токенов адреса отправителя другому кошельку.
    function approve(address _spender, uint256 _value) public returns (bool) {
        // Разрешаем использовать токены другому адресу. Если до этого были разрешены какие-то токены, разрешение переназначается.
        allowed[msg.sender][_spender] = _value;
        // Ивентируем разершение.
        emit Approval(msg.sender, _spender, _value);
        // Возвращаем true, если операция завершена успешно.
        return true;
    }
    
    // Функция, увеличивающая количество разрешённых токенов другому адресу. 
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        // Добавляем токены к разрешённым.
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        // Ивентируем разрешение.
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        // Возвращаем true, если операция завершена успешно.
        return true;
    }
    
    // Функция, снижающая количество разрешённых токенов другому адресу. 
    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        // Создаём переменную со старым количеством токенов.
        uint oldValue = allowed[msg.sender][_spender];
        // Проверяем, что при снижении токены не пойдут в минус.
        if (_subtractedValue > oldValue) {
            // В случае ухода в минус, принимаем количество разрешённых токенов, как нуль.
            allowed[msg.sender][_spender] = 0;
        } else {
            // В другом случае, просто уменьшаем количество разрешённых токенов на заданное число.
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        // Ивентируем разрешение.
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        // Возвращаем true, если операция завершена успешно.
        return true;
    }

    // Объявляем переменную с названием токена.
    string public name;

    // Объявляем переменную с символом токена.
    string public symbol;

    constructor() public {
        // Присваиваем название токена.
        name = "KorpusToken_Investment";
        // Присваиваем символ токена.
        symbol = "KTI";
    }

    // Функция создания токенов на адресе получателя.
    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        // Добавляем создаваемые токены к общему количеству.
        totalSupply = totalSupply.add(_amount);
        // Создаём токены на адресе получателя.
        balances[_to] = balances[_to].add(_amount);
        // Возвращаем true, если всё прошло успешно.
        return true;
    }
    
    // Функция сжигания токенов вклада на определённом адресе
    function burnFrom(address burner, uint256 _value) public {
        // Проверяем, что отправитель может сжечь это количество токенов.
        require(_value <= balances[burner]);
        // Проверка на то, что отправитель может использовать эти токены в переводе, имеет право их переводить.
        require(_value <= allowed[burner][msg.sender]);
        // Отнимаем от адреса отправителя токены.
        balances[burner] = balances[burner].sub(_value);
        // Уменьшаем общее количество токенов.
        totalSupply = totalSupply.sub(_value);
        // Снимаем разрешение на использование сжигаемого количества токенов кошелька пользователя с адреса отправителя.
        allowed[burner][msg.sender] = allowed[burner][msg.sender].sub(_value);
    }
}