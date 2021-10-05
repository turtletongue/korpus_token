// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Импортируем библиотеку для контроля доступа.
// Она позволяет управлять ролями пользователей.
import "@openzeppelin/contracts/access/AccessControl.sol";

// Импортируем стандартные возможности ERC20 токена.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract KorpusToken_Investment is ERC20, AccessControl {
    
    // Роли пользователей.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("KorpusToken_Investment", "KTI") {
        // Эта роль позволяет устанавливать роли.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Функция для проведения эмиссии.
    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _mint(to, amount);
    }
}
