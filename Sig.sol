// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/*
0. message to sign
1. hash(message)
2. sign(hash(message), private key) --offchain
3. ecrecover(hash(message), signature) == singer
*/

contract VerifySig{

    //最终验证地址（_singer）和加密后的输入的message(message)与签名(_sig)是否一致 (ecrecover(hash(message), signature) == singer) ,返回布尔值
    function Verify(address _singer, string memory _message, bytes memory _sig) external pure returns (bool){
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _sig) == _singer;
    }

    //第一次加密输入的message
    function getMessageHash(string memory _message) public pure returns (bytes32){
        return keccak256(abi.encodePacked(_message));
    }

    //第二次加密固定的字符串和第一次加密后的结果
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",_messageHash
        ));
    }

    //输入第二次加密的结果和签名后的r,s,v，通过ecrecover方法返回地址
    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address){
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash,v,r,s);
    }

    //通过非对称算法，加密签名，返回r,s,v
    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v){
        require(_sig.length == 65, "invalid signaure length");
        assembly {
            r := mload(add(_sig,32))
            s := mload(add(_sig,64))
            v := byte(0,mload(add(_sig,96)))
        }
    }
}
