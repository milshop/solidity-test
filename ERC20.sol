// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
    interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

    contract ERC20 is IERC20{

    mapping(address => uint256) public override balanceOf;   //地址代币余额

    mapping(address => mapping(address => uint256)) public override allowance; //一个地址给另一个地址合约的代币授权额度

    address public owner;
     //构造函数
    constructor() {
        owner = msg.sender;
    }

       //函数修改器
    modifier onlyOwner(){
        require(msg.sender == owner, "not owner");
        _;
    }

    uint256 public override totalSupply = 1000;   // 代币总供给

    string public name = "HUNKING";   // 名称
    string public symbol = "HUN";  // 代号
    uint8 public decimals = 18; // 小数位数

    //transfer()函数：实现IERC20中的transfer函数，代币转账逻辑。
    //调用方扣除amount数量代币，接收方增加相应代币。土狗币会魔改这个函数，加入税收、分红、抽奖等逻辑。
    function transfer(address recipient, uint amount) external override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }   

    //approve()函数：实现IERC20中的approve函数，代币授权逻辑。被授权方spender可以支配授权方的amount数量的代币。
    //spender可以是EOA账户，也可以是合约账户：当你用uniswap交易代币时，你需要将代币授权给uniswap合约。
    function approve(address spender, uint amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }   

    //transferFrom()函数：实现IERC20中的transferFrom函数，授权转账逻辑。
    //被授权方将授权方sender的amount数量的代币转账给接收方recipient。
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }    

    //mint()函数：铸造代币函数，不在IERC20标准中。
    //这里为了教程方便，任何人可以铸造任意数量的代币，实际应用中会加权限管理，只有owner可以铸造代币(已加入)：
    function mint(uint amount) external onlyOwner {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    //burn()函数：销毁代币函数，不在IERC20标准中。
     function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }   
    }

