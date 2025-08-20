// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract NFTAuction is Ownable {
    IERC721 public nft; //NFT  拥有者的合约地址
    constructor(address _nft) {
        nft = IERC721(_nft);
    }
    struct auction {
        address seller; //卖家
        uint256 auctionEndTime; //拍卖结束时间
        uint256 auctionStartTime; //拍卖开始时间
        uint tokenId; //NFT id
        uint startPrice; //起拍价
        bool active; //拍卖是否还在继续
        uint256 highestBid; //最高出价
        address highestBidder; //最高出价者
    }

    event AuctionCreated(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 startPrice,
        uint256 auctionEndTime
    );
    event BidPlaced(
        address indexed bidder,
        uint256 indexed tokenId,
        uint256 bidAmount
    );
    event AuctionEnded(
        address indexed winner,
        uint256 indexed tokenId,
        uint256 winningBid
    );

    //建立nft和拍卖的映射关系
    mapping(uint => auction) public auctions;

    function createAution(
        address _seller,
        uint256 _tokenId,
        uint _startPrice,
        uint _duration
    ) external {
        //创建竞拍的人 必须是NFT的拥有者
        require(
            nft.ownerOf(_tokenId) == msg.sender,
            "Not the owner of this NFT"
        );
         require(_duration > 0, "Duration must be > 0");
        //把NFT进行  托管
        //为什么要托管？？因为卖家可以在拍卖过程中随时转走NFT，这样竞拍的意义就没有了
        //所以需要托管  也就是把这个 NFT锁在  这个合约里面，卖家不能随便动！！！
        nft.transferFrom(msg.sender, address(this), _tokenId);

        auctions[_tokenId] = auction({
            seller: _seller,
            auctionEndTime: block.timestamp +_duration, // 示例结束时间
            auctionStartTime: block.timestamp,
            tokenId: _tokenId,
            startPrice: _startPrice,
            highestBid: 0, //初始化价格
            highestBidder: address(0), //初始化最高竞拍者地址
            active: true
        });

        emit AuctionCreated(_seller, _tokenId, _startPrice, auctions[_tokenId].auctionEndTime);
    }
    //出价，更新最高价 最高价地址    竞拍前价格检查  时间检查
    //出价如果更高  那么会进行实际支付
    //无需主动收款   因为只要定义了payable，并且调用者发送了msg.value，那么这笔eth会自动进入合约账户！！！！！！！！！！
    function bid(uint256 _tokenId) external payable {
        auction storage a = auctions[_tokenId];
        // 检查拍卖是否存在
        require(a.active, "Auction is not active");
        // 竞拍结束  则触发
        require(block.timestamp < a.auctionEndTime, "Auction has ended");
        //竞拍价  不能比  起拍价低
        require(
            msg.value >= a.startPrice,
            "Bid must be at least the starting price"
        );

        //如果当前价格比之前高
        require(
            msg.value > a.highestBid,
            "Bid must be higher than current highest bid"
        );

        //走到这里说明了  竞拍成功
        //如果之前有最高价  那么把钱   退还   给之前的最高价出价者
        if (a.highestBid > 0) {
            // payable(a.highestBidder).transfer(a.highestBid);
            //更安全的写法
            (bool success,)=payable(a.highestBidder).call{value: a.highestBid}("");
            require(success, "Failed to refund previous highest bidder");
        }
            a.highestBid = msg.value;
            a.highestBidder = msg.sender;
            // 记录新的最高出价者   nftid 最高出价
            emit BidPlaced(msg.sender, _tokenId, msg.value);
    }

    //结束拍卖
    function endAuction(uint256 _tokenId) external {
        auction storage a = auctions[_tokenId];
        //检查拍卖是否存在
        require(a.active, "Auction is not active");
        //检查拍卖是否结束
        require(block.timestamp >= a.auctionEndTime, "Auction has not ended yet");
        //检查调用者是否是卖家
        require(msg.sender == a.seller, "Only the seller can end the auction");

        //如果有最高出价者  那么把NFT转给他
        if (a.highestBidder != address(0)) {
            //address(this) 当前合约本身里面转移_tokenId  给a.highestBidder价格更高得地址！！
            nft.transferFrom(address(this), a.highestBidder, _tokenId);
            payable(a.seller).transfer(a.highestBid); //把钱转给卖家
        } else {
            //如果没有人出价，那么NFT退还给卖家
            nft.transferFrom(address(this), a.seller, _tokenId);
        }
        //标记拍卖为不活跃
        a.active = false;

        emit AuctionEnded(a.highestBidder, _tokenId, a.highestBid);
    }

}
