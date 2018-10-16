pragma solidity ^0.4.24;

import "../../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol";

contract ExchangeableToERC20 is ERC721BasicToken {
	ERC20 token;
	function exchange(address _to, uint256 _tokneId) public returns(bool);

	modifier onlyApprovaled( uint256 _tokenId ) {
		require( msg.sender == getApproved(_tokenId) );
		_;
	}

	// ERC721BasicToken
	function removeApproval(address _owner, uint256 _tokenId)
		public onlyApprovaled(_tokenId){
			super.clearApproval(_owner, _tokenId);
	}
}
