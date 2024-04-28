//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SGDT is ERC20 {

    uint8 private token_decimals;

    constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _totalSupply) 
        ERC20(_name, _symbol) {
        token_decimals = uint8(_decimals);
        _mint(msg.sender, _totalSupply / 10);
    }

    function decimals() public view override returns (uint8) {
        return uint8(token_decimals);
    }

    // faucet
    function faucet() public {
        uint256 _faucet_amount = 100 * 10**token_decimals;   // mint and transfer 100 tokens
        _mint(msg.sender, _faucet_amount);
    }
}