require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  settings: {
    optimizer: {
      enabled: true, // ✅ 如果你部署时开启了优化，这里也要 true
      runs: 200, // ✅ Hardhat 默认是 200，如果你改过就填你改的
    },
  },
  networks: {
    sepolia: {
      //指定 Hardhat 连接到哪个 以太坊节点（RPC endpoint）
      //也就是 Hardhat 部署合约、调用链上方法时要“发送交易”的目标节点
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`, // Replace with your Infura project ID
      //指定 Hardhat 使用哪个账户来部署合约、发送交易 钱包的私钥!!!!
      accounts: [
        process.env.MNEMONIC, // Replace with your wallet's mnemonic or private key
      ],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: "FJAJGQ12BIMPT27U86DJ4CJRDWZCMI4Y37", // ✅ 在 etherscan.io 注册后获取   API KEY
    },
  },
};
task("accounts", "Prints the list of accounts", async (_, hre) => {
  //hre.ethers.getSigners()  获取本地网络（或者指定网络）的账户列表。也就是
  const accounts = await hre.ethers.getSigners();
  accounts.forEach((account) => {
    console.log(account.address);
  });
});
