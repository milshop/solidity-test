// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract EtherWallet{
    address payable public owner;

    //构造函数，把合约拥有者的地址赋给owner
    constructor(){
        owner =payable(msg.sender);
    }

    receive() external payable{}

    function Withdraw(uint _amount) external{
        require(msg.sender == owner,"caller is not owner");
        payable(msg.sender).transfer(_amount);
    }

    function GetBalance() external view returns (uint) {
        return address(this).balance;
    }
}
