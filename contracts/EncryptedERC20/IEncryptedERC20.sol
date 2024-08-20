// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

import "fhevm/lib/TFHE.sol";

interface IEncryptedERC20 {
    /**
     * Standardize interface for encrypted ERC20.
     * 
     * Scope implementation: 
     * All the amount should remained encrypted. Meaning that for each transfert, we should not be 
     * able to see the amount exchange. Only the two parties can.
     * 
     * Try to adapt and replicate the IERC20 provided by OpenZeppelin.
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
     * 
     * Reference: https://www.zama.ai/post/confidential-erc-20-tokens-using-homomorphic-encryption
     *            https://github.com/zama-ai/fhevm/blob/main/examples/EncryptedERC20.sol
     */
    
    /**
     * @dev Emitted when a transfer of token is realized from one account (`from`) to
     * another (`to`).
     */
    event Transfer(address indexed from, address indexed to);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}.
     */
    event Approval(address indexed owner, address indexed spender);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint64);

    /**
     * @dev Returns the encrypted value of tokens owned by the owner.
     */
    function balance(bytes32 publicKey) external view returns (bytes memory);

    /**
     * @dev Moves an `encryptedValue` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address to, 
        einput encryptedValue, 
        bytes calldata proof
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner, 
        address spender, 
        bytes32 publicKey
    ) external returns (bytes memory);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {Approval} event.
     */
    function approve(
        address spender, 
        einput encryptedValue, 
        bytes calldata proof
    ) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from, 
        address to, 
        einput encryptedValue, 
        bytes calldata proof
    ) external returns (bool);

}