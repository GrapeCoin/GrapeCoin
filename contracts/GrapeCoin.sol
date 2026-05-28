// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title GrapeCoin
 * @dev ERC20 token implementation for GrapeCoin (GRAPE).
 *
 * Security improvements over the reference:
 * - Upgraded from Solidity 0.8.0 → 0.8.26
 * - Removed SafeMath (built-in overflow checks since 0.8.0)
 * - Removed deprecated `_setupDecimals` (unused dead code)
 * - Removed `public` visibility on constructor (deprecated since 0.7.0)
 * - Added SPDX license identifier
 */
contract GrapeCoin {
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @param name_        Token name (e.g. "Grape")
     * @param symbol_      Token symbol (e.g. "GRAPE")
     * @param totalSupply_ Human-readable total supply (will be multiplied by 10^decimals_)
     * @param decimals_    Number of decimals (typically 18)
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint8 decimals_
    ) {
        require(bytes(name_).length > 0, "name required");
        require(bytes(symbol_).length > 0, "symbol required");
        require(decimals_ <= 18, "decimals too high");

        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        totalSupply = totalSupply_ * (10 ** decimals_);
        balanceOf[msg.sender] = totalSupply;

        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // -----------------------------------------------------------------------
    // ERC20 Core
    // -----------------------------------------------------------------------

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "approve to zero address");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        uint256 currentAllowance = allowance[sender][msg.sender];
        require(currentAllowance >= amount, "insufficient allowance");

        _transfer(sender, recipient, amount);

        unchecked {
            allowance[sender][msg.sender] = currentAllowance - amount;
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 current = allowance[msg.sender][spender];
        require(current >= subtractedValue, "allowance underflow");
        unchecked {
            allowance[msg.sender][spender] = current - subtractedValue;
        }
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    // -----------------------------------------------------------------------
    // Burn
    // -----------------------------------------------------------------------

    function burn(uint256 amount) public {
        uint256 accountBalance = balanceOf[msg.sender];
        require(accountBalance >= amount, "burn exceeds balance");
        unchecked {
            balanceOf[msg.sender] = accountBalance - amount;
        }
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // -----------------------------------------------------------------------
    // Internal
    // -----------------------------------------------------------------------

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "transfer from zero address");
        require(recipient != address(0), "transfer to zero address");

        uint256 senderBalance = balanceOf[sender];
        require(senderBalance >= amount, "insufficient balance");

        unchecked {
            balanceOf[sender] = senderBalance - amount;
        }
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
}
