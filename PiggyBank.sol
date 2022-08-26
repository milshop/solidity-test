// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;


contract PiggyBank{

      event Deposit(uint amount);
      event WithDraw(uint amount);

    address public owner = msg.sender;

    receive() external payable{
        emit Deposit(msg.value);
    }

    function withdraw() external{
        require(msg.sender == owner,"not owner");
        emit WithDraw(address(this).balance);
        selfdestruct(payable(msg.sender));
    }
}
