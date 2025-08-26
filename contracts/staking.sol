// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

// IERC20接口 - 代币的标准接口（这个协议本身不包含铸造代币的方法，mint属于在这个协议之外拓展的）
interface MintableToken is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract Staking is ERC20Capped, Ownable {
    using SafeERC20 for IERC20;
    
    // ============ 常量定义 ============
    uint256 public constant STAKING_DURATION = 30 days;    // 质押时间（days是Solidity的时间字面量）
    uint256 public constant PRECISION = 1e12;              // 精度常量，用于避免整数除法带来的精度损失
    
    // ============ 状态变量 ============
    uint256 public totalStaked;                            // 合约中质押的总量
    uint256 public accRewardPerShare;                      // 每个代币累计的奖励
    uint256 public tokenNums = 1000000;                    // 初始奖励代币数量
    
    IERC20 public stakingToken;                            // ERC20 质押代币合约实例
    MintableToken public rewardToken;                      // ERC20实例，不过多了一个mint方法
    
    // ============ 数据结构 ============
    struct UserInfo {
        uint256 amount;                                    // 用户质押数量
        uint256 rewardDebt;                                // 用户的奖励债务
    }
    
    // 从记录用户的每次交易优化成记录用户的总质押数量
    mapping(address => UserInfo) public userInfo;

    // ============ 构造函数 ============
    constructor(address _stakingToken, address _rewardToken) 
        ERC20("Staked Token", "sToken") 
        ERC20Capped(1000000 * 1e18) { // 设定总供应上限为 100 万个代币，精确到 wei
        // _stakingToken - 质押代币类型的合约地址，拿到代币合约类型实例
        stakingToken = IERC20(_stakingToken);
        
        // _rewardToken - 铸币合约地址
        rewardToken = MintableToken(_rewardToken);
    }

    // ============ 管理员功能 ============
    /**
     * @notice 分发奖励给质押用户
     * @dev 只有合约所有者可以调用
     */
    function distributeRewards() external onlyOwner {
        // 铸造 1,000,000 个代币到质押合约的地址
        rewardToken.mint(address(this), tokenNums);

        // 如果池子里面有资金，需要更新每份份额的奖励
        if (totalStaked > 0) {
            accRewardPerShare += (tokenNums * PRECISION) / totalStaked;
        }
    }

    // ============ 用户功能 ============
    /**
     * @notice 用户质押代币
     * @param amount 质押数量
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        UserInfo storage user = userInfo[msg.sender];

        // 质押前进行奖励结算
        if (user.amount > 0) {
            // 质押总数 * 每股累计分红 - 已经结算过的分红 = 待领取分红
            uint256 pending = (user.amount * accRewardPerShare) / PRECISION - user.rewardDebt;
            
            if (pending > 0) {
                // 发放奖励
                safeRewardTransfer(msg.sender, pending);
            }
        }

        // 手动转移质押代币到合约（safeTransferFrom更安全，转账失败自动revert）
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        
        user.amount += amount;
        totalStaked += amount;
        
        // 这里是质押后用户最新的总分红数量 = 当前质押总数 * 目前每股的累计分红
        user.rewardDebt = (user.amount * accRewardPerShare) / PRECISION;

        // 铸造质押凭证代币
        _mint(msg.sender, amount);
    }

    /**
     * @notice 用户提取质押的代币和奖励
     * @param amount 提取数量
     */
    function withdraw(uint256 amount) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= amount, "Insufficient staked amount");
        
        // 奖励结算
        uint256 pending = (user.amount * accRewardPerShare) / PRECISION - user.rewardDebt;
        
        if (pending > 0) {
            // 奖励提现
            safeRewardTransfer(msg.sender, pending);
        }
        
        // 更新质押数量
        user.amount -= amount;
        totalStaked -= amount;
        
        // 质押代币提现
        stakingToken.safeTransfer(msg.sender, amount);
        
        // 更新用户的奖励债务
        user.rewardDebt = (user.amount * accRewardPerShare) / PRECISION;

        // 销毁质押凭证代币
        _burn(msg.sender, amount);
    }

    // ============ 视图函数 ============
    /**
     * @notice 查看用户的待领取奖励
     * @return 待领取的奖励数量
     */
    function pendingReward() public view returns (uint256) {
        UserInfo memory user = userInfo[msg.sender];
        uint256 pending = (user.amount * accRewardPerShare) / PRECISION - user.rewardDebt;
        return pending;
    }

    // ============ 内部函数 ============
    /**
     * @notice 安全转账奖励，防止合约奖励余额不足
     * @param to 接收地址
     * @param amount 转账金额
     * @dev 这里的余额是指当前质押账户在铸币合约中记录的余额
     */
    function safeRewardTransfer(address to, uint256 amount) internal {
        // 查询当前质押合约在奖励代币合约中的余额
        uint256 rewardBal = IERC20(address(rewardToken)).balanceOf(address(this));
        
        if (amount > rewardBal) {
            // 如果请求金额大于余额，只转账可用余额
            IERC20(address(rewardToken)).safeTransfer(to, rewardBal);
        } else {
            // 转账请求金额
            IERC20(address(rewardToken)).safeTransfer(to, amount);
        }
    }
}