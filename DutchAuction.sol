// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/AmazingAng/WTFSolidity/blob/main/34_ERC721/ERC721.sol";

contract DutchAuction is Ownable, ERC721 {

    /*
    COLLECTOIN_SIZE：NFT总量。
    AUCTION_START_PRICE：荷兰拍卖起拍价，也是最高价。
    AUCTION_END_PRICE：荷兰拍卖结束价，也是最低价/地板价。
    AUCTION_TIME：拍卖持续时长。
    AUCTION_DROP_INTERVAL：每过多久时间，价格衰减一次。
    auctionStartTime：拍卖起始时间（区块链时间戳，block.timestamp）。
    */
    uint256 public constant COLLECTOIN_SIZE = 10000; // NFT总数
    uint256 public constant AUCTION_START_PRICE = 1 ether; // 起拍价(最高价)
    uint256 public constant AUCTION_END_PRICE = 0.1 ether; // 结束价(最低价/地板价)
    uint256 public constant AUCTION_TIME = 10 minutes; // 拍卖时间，为了测试方便设为10分钟
    uint256 public constant AUCTION_DROP_INTERVAL = 1 minutes; // 每过多久时间，价格衰减一次
    uint256 public constant AUCTION_DROP_PER_STEP =
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
        (AUCTION_TIME / AUCTION_DROP_INTERVAL); // 每次价格衰减步长
    
    uint256 public auctionStartTime; // 拍卖开始时间戳
    string private _baseTokenURI;   // metadata URI
    uint256[] private _allTokens; // 记录所有存在的tokenId 

    //设定拍卖起始时间：我们在构造函数中会声明当前区块时间为起始时间，项目方也可以通过setAuctionStartTime()函数来调整
    constructor() ERC721("WTF Dutch Auctoin", "WTF Dutch Auctoin") {
        auctionStartTime = block.timestamp;
    }

    // auctionStartTime setter函数，onlyOwner
    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    /**
     * ERC721Enumerable中totalSupply函数的实现
     */
    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    /**
     * Private函数，在_allTokens中添加一个新的token
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

        //获取拍卖实时价格：getAuctionPrice()函数通过当前区块时间以及拍卖相关的状态变量来计算实时拍卖价格。
        //当block.timestamp小于起始时间，价格为最高价AUCTION_START_PRICE；
        //当block.timestamp大于结束时间，价格为最低价AUCTION_END_PRICE；
        //当block.timestamp处于两者之间时，则计算出当前的衰减价格。
    function getAuctionPrice(uint256 _auctionStartTime)
        public
        view
        returns (uint256)
    {
        if (block.timestamp < _auctionStartTime) {
        return AUCTION_START_PRICE;
        }else if (block.timestamp - _auctionStartTime >= AUCTION_TIME) {
        return AUCTION_END_PRICE;
        } else {
        uint256 steps = (block.timestamp - _auctionStartTime) /
            AUCTION_DROP_INTERVAL;
        return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    //用户拍卖并铸造NFT：用户通过调用auctionMint()函数，支付ETH参加荷兰拍卖并铸造NFT。
    //该函数首先检查拍卖是否开始/铸造是否超出NFT总量。接着，合约通过getAuctionPrice()和铸造数量计算拍卖成本，并检查用户支付的ETH是否足够：
    //如果足够，则将NFT铸造给用户，并退回超额的ETH；反之，则回退交易。
    // 拍卖mint函数
    function auctionMint(uint256 quantity) external payable{
        uint256 _saleStartTime = uint256(auctionStartTime); // 建立local变量，减少gas花费
        require(
        _saleStartTime != 0 && block.timestamp >= _saleStartTime,
        "sale has not started yet"
        ); // 检查拍卖是否开始
        require(
        totalSupply() + quantity <= COLLECTOIN_SIZE,
        "not enough remaining reserved for auction to support desired mint amount"
        ); // 检查是否超过NFT上限

        // Mint NFT
        for(uint i = 0; i < quantity; i++) {
            uint mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }

        uint256 totalCost = getAuctionPrice(auctionStartTime) * quantity; // 计算mint成本
        require(msg.value >= totalCost, "Need to send more ETH."); // 检查用户是否支付足够ETH
        // 多余ETH退款
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }    

        // 提款函数，onlyOwner
    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

}
