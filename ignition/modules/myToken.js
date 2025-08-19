const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
//部署合约脚本
module.exports = buildModule("MyTokenModule", (m) => {
  const initialSupply = m.getParameter("initialSupply", 1000000);

  const token = m.contract("MyToken", [initialSupply]);

  return { token };
});
