// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

// Импортируем библиотеку для контроля доступа.
// Она позволяет управлять ролями пользователей.
import "@openzeppelin/contracts/access/AccessControl.sol";

// Импортируем стандартные возможности ERC20 токена.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Импортируем токен стандарта ERC20, с возможностью сжигания токенов.
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract KorpusToken_Deposit is ERC20, ERC20Burnable, AccessControl {
    // Защищаем числа от переполнения.
    using SafeMath for uint256;

    // Передаём коструктору ERC20 имя и сокращение токена.
    constructor() ERC20("KorpusToken_Deposit", "KTD") {
        // Уставливаем роль администратора создателю токенов.
        // Эта роль позволяет устанавливать роли.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Создаём роль, обладающую правами на создание токенов.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // Создаём роль для бота.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Маппинг для хранения результатов оценки.
    // Название проекта -> ФИО студента -> Дата оценки -> Ось -> Количество баллов.
    mapping(string => mapping(string => mapping(uint256 => mapping(string => uint256)))) results;

    // Функция назначения результатов оценки определенного студента по одной из осей.
    function setStudentResult(
        string memory project,
        string memory student,
        uint256 date,
        string memory axis,
        uint256 points
    ) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        results[project][student][date][axis] = points;
    }

    // Функция, возвращающая результаты оценки определенного студента по одной из осей..
    function studentResults(
        string memory project,
        string memory student,
        uint256 date,
        string memory axis
    ) public view returns (uint256) {
        return results[project][student][date][axis];
    }

    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        // Вызываем внутреннюю функцию создания токенов.
        _mint(to, amount);
    }
}
