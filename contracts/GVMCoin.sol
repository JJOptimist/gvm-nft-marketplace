

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GamingVillage is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Gaming Village Metaverse", "GVM") {
        uint256 initialSupply = 1000000000000 * 10 ** uint256(decimals());
        _mint(msg.sender, initialSupply);
    }


}