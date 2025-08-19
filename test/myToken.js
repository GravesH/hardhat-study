const { expect } = require("chai");
const { ethers } = require("hardhat");
describe("myToken", function () {
  let myToken, owner, addr1, addr2;
  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners(); //获取测试账户
    console.log("owner address:", owner);
    console.log("addr1 address:", addr1);
    console.log("addr2 address:", addr2);
    // 获取合约工厂
    const MyToken = await ethers.getContractFactory("MyToken");
    myToken = await MyToken.deploy(100000); // 部署合约
    await myToken.waitForDeployment(); // 等待合约部署完成
  });
  it("owner 拥有的初始代币", async () => {
    console.log("owner address:", owner);
    // owner 应该拥有 100000 个代币
    expect(await myToken.balanceOf(owner.address)).to.equal(100000);
    it("可以转账给： addr1", async () => {
      await myToken.transfer(addr1.address, 1000); // owner 转账 1000 个代币给 addr1
      expect(await myToken.balanceOf(addr1.address)).to.equal(100);
    });
  });
});
