pragma solidity ^0.4.24;

import "./testToken20.sol";
import "./ExchangeableToERC20.sol";
import "./Auction.sol";
import "../../../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";

contract MyToken721 is ERC721Token, ExchangeableToERC20{

	string public name = "My Test Exchangable ERC721 Token";
	string public symbol = "MET";

	MyToken20 public token;

	Auction auction;

	constructor(MyToken20 _token) 
		public ERC721Token(name, symbol) ExchangeableToERC20(_token){
			token = _token;
		}

	function exchange(address _to, uint256 _tokenId, uint256 _value) public returns(bool) {
		if( token.transferFrom(_to, msg.sender, _value) )
			return false;

		this.transferFrom(msg.sender, _to, _tokenId);

		return true;
	}

	function mint(address _to, uint256 _tokenId) public {
		_mint(_to, _tokenId);
	}

	function sell(
		Auction _auction,
		uint256 _tokenId, uint256 _reservePrice, uint256 _timeoutPeriod, uint256 _auctionEnd)
		public {

		auction = _auction;
		auction.initAuction(
			this, _tokenId, _reservePrice, _reservePrice/10, _timeoutPeriod, _auctionEnd
		);

	}
}
