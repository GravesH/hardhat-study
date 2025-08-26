const { expect } = require("chai");
const { ethers } = require("hardhat");
describe("staking", function () {
  let myToken, staking, owner, addr1, addr2;
  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();

    // 部署质押代币（用户 stake 用的）
    const StakingToken = await ethers.getContractFactory("StakingToken");
    stakingToken = await StakingToken.deploy(1000000);
    await stakingToken.waitForDeployment();

    // 部署奖励代币（带 mint 功能）
    const MyToken = await ethers.getContractFactory("MyToken");
    myToken = await MyToken.deploy(100000);
    await myToken.waitForDeployment();

    // 部署 Staking（传入两个地址）
    const Staking = await ethers.getContractFactory("Staking");
    staking = await Staking.deploy(stakingToken.target, myToken.target);
    await staking.waitForDeployment();

    // 设置 staking 为奖励代币的 minter
    await myToken.setMinter(staking.target);
  });

  it("owner 拥有的初始代币", async () => {
    console.log("owner address:", owner);
    // owner 应该拥有 100000 个代币
    expect(await myToken.balanceOf(owner.address)).to.equal(100000);
  });

  it("可以转账给： addr1", async () => {
    await myToken.transfer(addr1.address, 1000); // owner 转账 1000 个代币给 addr1
    expect(await myToken.balanceOf(addr1.address)).to.equal(1000);
  });

  it("addr1 可以质押代币", async () => {
    // owner 转账 1000 个质押代币给 addr1
    await stakingToken.transfer(addr1.address, 1000);
    expect(await stakingToken.balanceOf(addr1.address)).to.equal(1000);

    // addr1 授权质押合约可以花费其代币
    const stakingTokenAddr1 = stakingToken.connect(addr1);
    //允许质押合约最多花费 addr1 的 500 个代币
    const approveTx = await stakingTokenAddr1.approve(staking.target, 600);
    await approveTx.wait();

    // 检查授权是否成功
    const allowance = await stakingTokenAddr1.allowance(
      addr1.address,
      staking.target
    );
    expect(allowance).to.equal(600);
    console.log("allowance:", addr1, allowance);
    // addr1 质押 500 个代币
    //connect切换合约调用者身份
    const stakingAddr1 = staking.connect(addr1);
    const stakeTx = await stakingAddr1.stake(600);
    await stakeTx.wait();
    const userInfo = await stakingAddr1.userInfo(addr1.address);
    expect(userInfo.amount).to.equal(600);
    expect(await stakingToken.balanceOf(addr1.address)).to.equal(400); // addr1 余额减少
  });
});
