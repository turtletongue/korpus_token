// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Импортируем библиотеку для контроля доступа.
// Она позволяет управлять ролями пользователей.
import "@openzeppelin/contracts@4.9.5/access/AccessControl.sol";

// Импортируем стандартные возможности ERC20 токена.
import "@openzeppelin/contracts@4.9.5/token/ERC20/ERC20.sol";

// Объявляем интерфейс основного смарт-контракта.
interface KorpusContract {
    function isInSellers(address addr) external view returns (bool isSeller);
    
    function getTrader() external view returns (address trader);
}

contract KorpusToken_Deposit is ERC20, AccessControl {
    
    // Роли пользователей.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    constructor() ERC20("KorpusToken_Deposit", "KTD") {
        // Эта роль позволяет устанавливать роли.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Маппинг для хранения результатов оценки.
    // Название проекта -> ФИО студента -> Дата оценки -> Ось -> Количество баллов.
    mapping(string => mapping(string => mapping(uint256 => mapping(string => uint256)))) results;

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

    function studentResults(
        string memory project,
        string memory student,
        uint256 date,
        string memory axis
    ) public view returns (uint256) {
        return results[project][student][date][axis];
    }
    
    KorpusContract public _mainContract;
    
    function setMainContract(KorpusContract mainContract) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _mainContract = mainContract;
    }

    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _mint(to, amount);
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20) {
        if (address(this) != from && address(_mainContract) == to) {
            require(_mainContract.isInSellers(from) || _mainContract.getTrader() == from, "Blocked");
        }
        
        super._beforeTokenTransfer(from, to, amount);
    }
}
