pragma solidity ^0.4.25;

import "./Auction.sol";
import "./testToken721.sol";
import "../../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../../../node_modules/openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

contract MyToken20 is MintableToken{
	string public name = "My Test Token";
	string public symbol = "MTT";
	uint8  public decimal = 18;

	using SafeMath for uint256;

	MyToken721 token;

	function setToken(MyToken721 _token) public{
		token = _token;
	}

	event Bid(address _who, address _where, uint256 _value);
	function bid(Auction _auction, uint256 _amount) public returns(bool){
		Auction auction = _auction;

		uint256 lastBid = allowance(msg.sender, address(token) );
		if(lastBid == 0) {
			approve( address(token), _amount );
		} else {
			uint256 increment = _amount.sub(lastBid);
			increaseApproval( address(token), increment );
		}

		require(allowance( msg.sender, address(token)) == _amount );
		uint256 bidAmount = auction.bid(this, _amount);
		require(allowance( msg.sender, address(token)) == bidAmount);

		emit Bid(msg.sender, token, bidAmount);

		return true;
	}
}
