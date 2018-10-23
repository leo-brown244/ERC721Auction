const Contract20 = artifacts.require("MyToken20");
const Contract721 = artifacts.require("MyToken721");
const ContractAuction = artifacts.require("Auction");

module.exports = function(deployer){

//	var now = Date.now();
//	var period = new Date().setSeconds(10).valueOf();
//	var totalTestTime = new Date().setMinutes(1).valueOf();
//
//	var reservePrice = web3.toWei(1000, "ether");
//	var minIncrement = web3.toWei(10, "ether");
//	var timeOutPeriod = new web3.BigNumber( period );
//	var auctionEnd = new web3.BigNumber( now + totalTestTime );


	deployer.deploy(Contract20).then(function(){
		return deployer.deploy(ContractAuction);
	}).then(function(){
		return deployer.deploy(Contract721, Contract20.address);
	});

};
