// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    uint256 public annualRewardRate = 10; // 代表 10% 的年化利率

    //设计一个质押信息结构体
    struct Deposit {
        uint256 amount;
        uint256 startTime;
    }

    mapping(address => Deposit[]) public deposits;

    function stake() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        //账本记录 当前用户质押数量

        deposits[msg.sender].push(
            Deposit({amount: msg.value, startTime: block.timestamp})
        );
        //质押到合约  transferFrom只适用于代币转移   不适用于原生ETH！！！！
        //原生ETH 不需要用方法接收有  payable属性就够了
        // token.transferFrom(msg.sender, address(this), msg.value);
    }

    function withdraw() external returns (bool) {
        return true;
    }

    function calculateReward() external returns (bool) {}
}
