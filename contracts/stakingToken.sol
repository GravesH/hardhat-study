// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Staking Token", "STK") {
        _mint(msg.sender, initialSupply); // 给部署者初始供应
    }
}
