// const { ethers } = require("hardhat");
// async function main() {
//   //首先部署代币合约
//   const MyToken = await ethers.getContractFactory("myToken");
//   const mytoken = await MyToken.deploy(100000000);
//   await mytoken.deployed();
//   console.log("MyToken deployed to:", mytoken.address);

//   //然后部署质押合约
//   const Staking = await ethers.getContractFactory("staking");
//   //传入奖励代币的地址 和质押代币的地址
//   //这里质押代币和奖励代币是同一种
//   const staking = await Staking.deploy(mytoken.address);
//   await staking.deployed();
//   console.log("Staking deployed to:", staking.address);

//   //授权，调用代币合约的方法，设置质押合约为minter，允许其发币！！！！
//   const serMinterTx = await mytoken.setMinter(staking.address);
//   await serMinterTx.wait();
//   console.log("set minter ok");
// }
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });
const { ethers } = require("hardhat");

async function main() {
  // 1) 部署“质押用代币”（用户 stake 的那个）
  const StakingToken = await ethers.getContractFactory("StakingToken");
  const stakingToken = await StakingToken.deploy(1_000_000n * 10n ** 18n);
  await stakingToken.waitForDeployment();
  console.log("StakingToken:", stakingToken.target);

  // 2) 部署“奖励代币”（可 mint）
  const MyToken = await ethers.getContractFactory("MyToken");
  const myToken = await MyToken.deploy(100_000n * 10n ** 18n);
  await myToken.waitForDeployment();
  console.log("MyToken:", myToken.target);

  // 3) 部署质押合约（传入两个地址：质押代币 + 奖励代币）
  const Staking = await ethers.getContractFactory("Staking");
  const staking = await Staking.deploy(stakingToken.target, myToken.target);
  await staking.waitForDeployment();
  console.log("Staking:", staking.target);

  // 4) 授予 Staking 为奖励代币的 minter
  const tx1 = await myToken.setMinter(staking.target);
  await tx1.wait();
  console.log("setMinter ok");

  // 5) 将奖励代币的所有权转移给 Staking（为满足 onlyOwner）
  const tx2 = await myToken.transferOwnership(staking.target);
  await tx2.wait();
  console.log("transferOwnership to Staking ok");
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});