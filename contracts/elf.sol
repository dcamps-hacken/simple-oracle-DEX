//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Elf is ERC20, Ownable {
    constructor()
        /* address _dex  */
        ERC20("WizardCoin", "WZD")
    {
        _mint(msg.sender, 1e10 * 10**decimals());
    }

    function mint(address _to, uint256 _amount) external {
        uint256 amount = _amount * 10**decimals();
        _mint(_to, amount);
    }
}
