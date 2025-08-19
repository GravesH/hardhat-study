// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract MyToken is ERC20, Ownable {
    //给下面代码加注释
    // 构造函数，初始化代币名称和符号，并铸造初始供应量
    // `initialSupply` 是初始供应量，单位是最小单位（如 wei 对于以太币）
    // `ERC20` 是 OpenZeppelin 提供的标准 ERC20 代币
    // `Ownable` 是 OpenZeppelin 提供的合约，用于管理合约所有者
    // `msg.sender` 是部署合约的地址，初始供应量将分配给该地址
    // `_mint` 函数用于铸造代币，将初始供应量分配给合约所有者
    constructor(uint256 initialSupply) ERC20('MYToken','hzy66'){
        _mint(msg.sender, initialSupply);
    }   
    //初始化的时候  已经新增了代币   提供方法 继续增发数量
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    } 
}
