const { ethers } = require("hardhat");
async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("部署账户:", deployer.address);

  // 1. 部署 Factory
  // 注意：这里直接使用字符串 'UniswapV2Factory'
  // Hardhat会自动在node_modules/@uniswap/v2-core/artifacts/contracts 中找到它
  const UniswapV2Factory = await ethers.getContractFactory("UniswapV2Factory");
  const uniswapV2Factory = await UniswapV2Factory.deploy(deployer.address);
  await uniswapV2Factory.waitForDeployment();
  console.log("UniswapV2Factory deployed to:", uniswapV2Factory.target);
  const UniswapV2Router02 = await ethers.getContractFactory(
    "UniswapV2Router02"
  );
  console.log("UniswapV2Router02 deploying...");
  const uniswapV2Router02 = await UniswapV2Router02.deploy(
    uniswapV2Factory.target,
    "FJAJGQ12BIMPT27U86DJ4CJRDWZCMI4Y37" // WETH 地址，主网和 sepolia 都是这个地址
  );
  await uniswapV2Router02.waitForDeployment();
}
