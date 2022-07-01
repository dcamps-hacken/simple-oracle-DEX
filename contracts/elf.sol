//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Elf is ERC20, Ownable {
    constructor() ERC20("ElfCoin", "ELF") {
        _mint(msg.sender, 1e10 * 10**decimals());
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}
