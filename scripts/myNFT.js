const { ethers } = require("hardhat");
async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("部署账户:", deployer.address);
  const MyNFT = await ethers.getContractFactory("myNFT");
  const myNFT = await MyNFT.deploy();
  await myNFT.waitForDeployment();
  console.log("myNFT 合约地址:", myNFT);
  console.log("myNFT deployed to:", await myNFT.getAddress());

  // 直接 mint 给你自己
  const tx = await myNFT.safeMint(deployer.address);
  await tx.wait();
  console.log("成功 mint 给:", deployer.address);
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
// 运行脚本：npx hardhat run scripts/myNFT.js --network sepolia
// 运行脚本时指定网络，确保在 hardhat.config.js 中配置了 sepolia 网络
// 如果没有配置 sepolia 网络，可以使用 npx hardhat node 启动本地测试网络
// 然后运行脚本时使用 --network localhost
