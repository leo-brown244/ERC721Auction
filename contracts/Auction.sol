pragma solidity ^0.4.24;

import "./ExchangeableToERC20.sol";
import "../../../node_modules/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
//import "../../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

/**
**	https://programtheblockchain.com/posts/2018/03/20/writing-a-token-auction-contract/
**	위 링크를 참고하여 티켓 경매 컨트랙트를 구현한다.
**
**	Bidding에 필요한 재화는 Ether가 아닌 KGEtoken이다.
**	최종 낙찰된 시점에 교환이 이루어진다.
**
**	본 컨트랙트는 티켓 소유자가 재판매할 때 발행된다.
**
**	TODO
**	하나의 경매 컨트랙에서 모든 티켓 판매가 이루어지는 방법과 성능을 비교한다.
*/

contract Auction {

	using SafeMath for uint256;

	ExchangeableToERC20	public item;
	ERC20 	public token;

	address seller;
	uint256 item_Id;

	uint256 public reservePrice;
	uint256 public minIncrement;
	uint256 public timeoutPeriod;

	uint256 public auctionEnd;	

	constructor(
	) public {
	}

	function initAuction(
		ExchangeableToERC20	_item,
		uint256 _item_Id,
		uint256 _reservePrice,
		uint256 _minIncrement,
		uint256 _timeoutPeriod
	) public {
		// KGEticket 컨트랙트에서 발행되는 스마트 컨트랙트이다.
		// TODO Contract Account에서 Contract Account 발행하는 방법

		item = _item;
		token = item.token();

		seller = msg.sender;
		item_Id = _item_Id;

		reservePrice = _reservePrice;
		minIncrement = _minIncrement;
		timeoutPeriod = _timeoutPeriod;

		auctionEnd = now.add( timeoutPeriod );  
	}

	/*
	**	입찰 기능 구현
	**	입찰 후 token의 allowed를 수정할 가능성 및 낙찰자의 토큰 잔고가 부족할 수 있다.
	**	이 경우 차상위 입찰자가 낙찰받는다.
	*/
	address highBidder;	// 현재 최고 입찰자
	address[] lastHighBidderList;		// 지난 최고 입찰자 명단, 순서대로 기록한다.
	mapping(address => uint256) bidAmount;	// 입찰시 금액을 기록한다.
	event Bid(address highBidder, uint256 highBid);

	function bid(ERC20 _token, uint256 _amount) public returns(uint256){	// msg.sender == bidder
		require(now < auctionEnd);
		require(_amount >= reservePrice);
		require(_amount >= bidAmount[highBidder]+minIncrement);

		require(token == _token);	// 지정된 토큰만 받는다.

		bidAmount[msg.sender] = _amount;
		//require(token.allowance( msg.sender, address(this)) == bidAmount[msg.sender] );	//revert here
		// token.allowance(msg.sender, address(this)) return 0;

		// 최상이 입찰자 수정
		if( highBidder != address(0) )
			lastHighBidderList.push(highBidder);
		highBidder = msg.sender;

		auctionEnd = now.add( timeoutPeriod );

		emit Bid(highBidder, _amount);
		return bidAmount[msg.sender];
		//return token.allowance(msg.sender, address(this));	// return 0;
	}

	/**
	**	경매 결과에 따라 티켓과 토큰을 교환한다.
	**
	*/
	event AuctionFailure(uint256 _item_Id);
	event AuctionSuccess(address _seller, address _winner, uint256 _item_Id, uint256 _value);

	function resolve() public returns(bool){
		require(now >= auctionEnd);

		if( highBidder == address(0) ){
			// 유찰
			_auctionFail();
		} else {
			// 낙찰
			// 아무도 잔고를 남겨놓지 않으면 주인에게 돌아간다.
			if ( _transferItem() )
				emit AuctionSuccess(seller, 
														highBidder, 
														item_Id,
														bidAmount[highBidder]
													 );
			else {
				_auctionFail();
			}
		}
		return true;
	}

	function _transferItem() private returns(bool){
		bool isExchanged = false;
		uint256 value = bidAmount[highBidder];

		for(uint256 index = lastHighBidderList.length ; index >= 0 ; index-- ){
			if( item.exchange( highBidder, item_Id, value ) == true){
				isExchanged = true;
				break;
			} else {
				highBidder = lastHighBidderList[ index ];
				value = bidAmount[highBidder];
			}
		}

		return isExchanged;
	}

	function _auctionFail() private {
		item.removeApproval(seller, item_Id);
		emit AuctionFailure(item_Id);
	}

}







