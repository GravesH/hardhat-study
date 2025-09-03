const { expect } = require("chai");
const { ethers } = require("hardhat");
describe("PriceConsumer", function () {
  let priceConsumer, owner, addr1, addr2;
  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners(); //获取测试账户
    console.log("owner address:", owner);
    console.log("addr1 address:", addr1);
    console.log("addr2 address:", addr2);
    // 获取合约工厂
    const PriceConsumer = await ethers.getContractFactory("PriceConsumer");
    priceConsumer = await PriceConsumer.deploy(); // 部署合约
    await priceConsumer.waitForDeployment(); // 等待合约部署完成
  });
  it("getLatestPrice", async () => {
    const price = await priceConsumer.getLatestPrice();
    console.log("price:", price);
    //价格转换为eth单位
    const formatted = ethers.formatUnits(price, 8);
    console.log("formatted price (ETH/USD):", formatted);
    expect(price).to.be.a("bigint");
  });
});
