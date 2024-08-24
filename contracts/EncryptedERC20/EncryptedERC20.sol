// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;


import "fhevm/lib/TFHE.sol";

import "./IEncryptedERC20.sol";
import "./IEncryptedERC20Errors.sol";

contract EncryptedERC20 is IEncryptedERC20, IEncryptedERC20Errors {
    uint64 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(address account => euint64) internal _balances;

    mapping(address account => mapping(address spender => euint64)) internal _allowances;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        // FIXME :: Need to see if this kind of precision is not an issue with encrypted
        // data using FHE.

        // FIXME :: Using the one provided by ZAMA example instead of 18 defined usually.
        return 6;
    }

    function totalSupply() external view override returns (uint64) {
        return _totalSupply;
    }

    function balance() external view override returns (euint64) {
        return _balances[msg.sender];
    }

    function transfer(address to, einput encryptedValue, bytes calldata proof) external override returns (bool) {
        if (to == address(0)) { revert ERC20InvalidReceiver(address(0)); }

        euint64 value = TFHE.asEuint64(encryptedValue, proof);
        require(TFHE.isSenderAllowed(value));
        
        ebool canTransfer = TFHE.le(value, _balances[msg.sender]);
        _transfer(msg.sender, to, value, canTransfer);
        return true;
    }

    function _transfer(address from, address to, euint64 amount, ebool isTransferable) internal virtual {
        // Add to the balance of `to` and subract from the balance of `from`.
        euint64 transferValue = TFHE.select(isTransferable, amount, TFHE.asEuint64(0));
        euint64 newBalanceTo = TFHE.add(_balances[to], transferValue);
        _balances[to] = newBalanceTo;

        // Allow this new balance for both the contract and the owner.
        TFHE.allow(newBalanceTo, address(this));
        TFHE.allow(newBalanceTo, to);
        
        euint64 newBalanceFrom = TFHE.sub(_balances[from], transferValue);
        _balances[from] = newBalanceFrom;

        // Allow this new balance for both the contract and the owner.
        TFHE.allow(newBalanceFrom, address(this));
        TFHE.allow(newBalanceFrom, from);
        emit Transfer(from, to);
    }

    function allowance(address owner, address spender) external view override returns (euint64) {
        return _allowances[owner][spender];  // Seems only msg.sender could decrypt it
    }

    function approve(address spender, einput encryptedValue, bytes calldata proof) external override returns (bool) {
        if (spender == address(0)) { revert ERC20InvalidSpender(address(0)); }

        euint64 value = TFHE.asEuint64(encryptedValue, proof);
        require(TFHE.isSenderAllowed(value));

        _allowances[msg.sender][spender] = value;
        
        // Authorize other actors to see the value
        TFHE.allow(value, address(this));
        TFHE.allow(value, msg.sender);
        TFHE.allow(value, spender);
    }

    function transferFrom(
        address from,
        address to,
        einput encryptedValue,
        bytes calldata proof
    ) external override returns (bool) {
        euint64 value = TFHE.asEuint64(encryptedValue, proof);
        
        require(TFHE.isSenderAllowed(value));
        ebool isTransferable = _spendAllowance(from, msg.sender, value);
        _transfer(from, to, value, isTransferable);
        return true;

    }


    // FIXME :: Seems that we are using the 'select' operator instead of 'require' one
    // to proceed or not the transaction. Meaning that if the transaction is invalid,
    // we will adjust the potential transferable value.
    //
    // This raise the following questions:
    // Why not use a require ? 
    // - As we will need to decypher the value is it more costly ?
    // - We want to keep privacy, and in this logic, we intend to not crash ? (Does 
    // make sense in personal transfer as I know the value, but maybe for transfer_from?)

    function _spendAllowance(
        address from, 
        address to, 
        euint64 value
    ) internal returns (ebool) {
        euint64 currentAllowance = _allowances[from][to];
        ebool allowTransfer = TFHE.le(value, currentAllowance);

        ebool isFunded = TFHE.le(value, _balances[from]);
        ebool isTransferable = TFHE.and(allowTransfer, isFunded);

        ebool possible = TFHE.le(value, _allowances[from][to]);

        euint64 newAllowance = TFHE.select(
            isTransferable, 
            TFHE.sub(currentAllowance, value), 
            currentAllowance
        );

        _allowances[from][to] = newAllowance;
        TFHE.allow(newAllowance, address(this));
        TFHE.allow(newAllowance, from);
        TFHE.allow(newAllowance, to);
        
        return possible;
    }


}