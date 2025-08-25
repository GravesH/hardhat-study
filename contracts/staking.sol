// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//注释： IERC20接口  代币的标准接口（这个协议本身不包含铸造代币的方法，mint属于在这个协议之外拓展的）
interface MyToken is IERC20 {
    function mint(address to, uint256 amount) external;
}
contract Staking is Ownable {
    uint256 public annualRewardRate = 10; // 代表 10% 的年化利率
    //质押时间    days是Solidity的时间字面量   并不是string
    uint256 public constant STAKING_DURATION = 30 days;
    struct UserInfo {
        uint256 amount; //用户质押数量
        uint256 rewardDebt; //用户的奖励债务
    }

    // mapping(address => Deposit[]) public deposits;
    //从记录用户的每次交易 优化成  记录用户的总质押数量
    mapping(address => UserInfo) public userInfo;

    uint256 public totalStaked; //合约中质押的总量
    uint256 public accRewardPerShare; //每个代币累计的奖励

    uint256 public tokenNums = 1000000; //初始奖励代币数量
    uint256 public constant PRECISION = 1e12; // 精度常量，用于避免整数除法带来的精度损失
    MyToken public token;
    constructor(address tokenAddress) {
        //拿到的token是  传入的合约实例，通过这个拿到的实力去调用mint方法！！！！！！
        token = MyToken(tokenAddress);
    }

    function distributeRewards() external onlyOwner {
        // 铸造 1,000,000 个代币到质押合约的地址
        token.mint(address(this), tokenNums);

        //如果池子里面有资金  需要更新每份份额的奖励
        if (totalStaked > 0) {
            accRewardPerShare += (tokenNums * PRECISION) / totalStaked;
        } 
    }
    function stake() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        //账本记录 当前用户质押数量
        UserInfo storage user = userInfo[msg.sender];
        
        //质押前进行  奖励结算
        if (user.amount > 0) {
            //质押总数*每股累计分红 - 已经结算过的分红= 待领取分红
            uint256 pending = (user.amount * accRewardPerShare) /
                PRECISION -
                user.rewardDebt;
            if (pending > 0) {
                //发放奖励
                token.transfer(msg.sender, pending);
            }
        }

        user.amount += msg.value;

        totalStaked += msg.value;
        //这里是质押后用户  最新的 总分红数量 =  当前质押总数 * 目前每股的累计分红

        user.rewardDebt = (user.amount * accRewardPerShare) / PRECISION;

        //质押到合约  transferFrom只适用于代币转移   不适用于原生ETH！！！！
        //原生ETH 不需要用方法接收有  payable属性就够了
        // token.transferFrom(msg.sender, address(this), msg.value);
    }

    function withdraw() external {}

    //查看用户的待领取奖励
    function pendingReward() public view returns (uint256) {
        UserInfo memory user = userInfo[msg.sender];
        uint256 pending = (user.amount * accRewardPerShare) /
            PRECISION -
            user.rewardDebt;
        return pending;
    }
}
