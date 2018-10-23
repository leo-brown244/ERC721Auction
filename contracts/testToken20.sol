pragma solidity ^0.4.24;

import "./Auction.sol";
import "../../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../../../node_modules/openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

contract MyToken20 is MintableToken{
	string public name = "My Test Token";
	string public symbol = "MTT";
	uint8  public decimal = 18;

	using SafeMath for uint256;

	event Bid(address _who, address _where, uint256 _value);
	function bid(Auction _auction, uint256 _amount) public returns(bool){
		Auction auction = _auction;

		uint256 lastBid = allowance(msg.sender, address(_auction) );
		if(lastBid == 0) {
			approve( address(_auction), _amount );
		} else {
			uint256 increment = _amount.sub(lastBid);
			increaseApproval( address(_auction), increment );
		}

		require(allowance( msg.sender, address(_auction)) == _amount );
		uint256 bidAmount = auction.bid(this, _amount);
		require(allowance( msg.sender, address(_auction)) == bidAmount);

		emit Bid(msg.sender, _auction, bidAmount);

		return true;
	}
}
