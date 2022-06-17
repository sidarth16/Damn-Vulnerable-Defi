// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title AttackRewarder
 * @author sidarth16
 */

interface IFlashLoanerPool{
    function flashLoan(uint256 amount) external;
}

contract AttackRewarder {

    using Address for address;

    address public pool;
    address public liquidityToken ;

    constructor (address _pool, address _liquidityTokenAddress) {
        pool = _pool;
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
    }

    function attack(uint256 amt) external
    {
        IFlashLoanerPool(pool).flashLoan(amt);
        liquidityToken.transfer(pool, amt);
        
    }

}
