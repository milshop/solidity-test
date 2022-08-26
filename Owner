// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Ownable {
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

    //转移owner权限
    function setOwner(address _newOwner) external onlyOwner{
        require (_newOwner != address(0), "invalid address");
        owner = _newOwner;
    }

    //测试owner
    function testOnlyOwnerfunc() external onlyOwner{
        //code
    }

    function testAnyOwnerfunc() external{
        //code
    }

}
