// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

// Импортируем библиотеку для контроля доступа.
// Она позволяет управлять ролями пользователей.
import "@openzeppelin/contracts/access/AccessControl.sol";

// Импортируем стандартные возможности ERC20 токена.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Импортируем токен стандарта ERC20, с возможностью сжигания токенов.
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract KorpusToken_Investment is ERC20, ERC20Burnable, AccessControl {
    // Защищаем числа от переполнения.
    using SafeMath for uint256;

    // Создаём роль, обладающую правами на создание токенов.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Передаём коструктору ERC20 имя и сокращение токена.
    constructor() ERC20("KorpusToken_Investment", "KTI") {
        // Уставливаем роль администратора создателю токенов.
        // Эта роль позволяет устанавливать роли.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        // Вызываем внутреннюю функцию создания токенов.
        _mint(to, amount);
    }
}
