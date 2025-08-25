const { ethers } = require("hardhat");
async function main() {
  //首先部署代币合约
  const MyToken = await ethers.getContractFactory("myToken");
  const mytoken = await MyToken.deploy(100000000);
  await mytoken.deployed();
  console.log("MyToken deployed to:", mytoken.address);

  //然后部署质押合约
  const Staking = await ethers.getContractFactory("staking");
  //传入奖励代币的地址 和质押代币的地址
  //这里质押代币和奖励代币是同一种
  const staking = await Staking.deploy(mytoken.address);
  await staking.deployed();
  console.log("Staking deployed to:", staking.address);

  //授权，调用代币合约的方法，设置质押合约为minter，允许其发币！！！！
  const serMinterTx = await mytoken.setMinter(staking.address);
  await serMinterTx.wait();
  console.log("set minter ok");
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
