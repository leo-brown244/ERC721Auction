const Contract20 = artifacts.require("MyToken20");
const Contract721 = artifacts.require("MyToken721");
const ContractAuction = artifacts.require("Auction");

const { latestTime } = require('../../../node_modules/openzeppelin-solidity/test/helpers/latestTime');
const { increaseTimeTo, duration } = require('../../../node_modules/openzeppelin-solidity/test/helpers/increaseTime');

contract("Auction Test", async()=>{

	var token20;
	var token20Amount = 10000;
	var token721;
	var token721Id = 101;
	var auction;

	var manager = web3.eth.accounts[0];
	var seller = web3.eth.accounts[1];
	var bidder = new Array();

	for(var i = 0; i < 8 ; i++){
		bidder[i] = web3.eth.accounts[i];
	}

	it("Get deployed contract", async()=>{
		token20 	= await Contract20.deployed();
		token721 	= await Contract721.deployed();
		auction 	= await ContractAuction.deployed();

		await token20.setToken(token721.address, {from:manager});

		assert.isTrue(token20 != null);
		assert.isTrue(token721 != null);
		assert.isTrue(auction != null);
	});

	it("Mint token", async()=>{

		// erc20 토큰 발행
		var tokenAmountWei = web3.toWei(token20Amount);
		for(var i = 0; i < 8 ; i++){
			await token20.mint(bidder[i], tokenAmountWei, {from:manager});
		}

		// erc721 토큰 발행
		await token721.mint(seller, token721Id, {from:manager});
		// 721 토큰 소유자 확인
		assert.equal( seller, await token721.ownerOf(token721Id) );
	});

	it("Init auction", async()=>{

		var now = Date.now();
		var period = new Date().setSeconds(30).valueOf();

		var reservePrice = web3.toWei(1000, "ether");
		var timeOutPeriod = new web3.BigNumber( period ).toNumber();
		//var timeOutPeriod = period;
		timeOutPeriod = duration.seconds(60);

		await token721.sell(
			auction.address,
			token721Id,
			reservePrice,
			timeOutPeriod,
			{from:seller}
		);

	});

	it("Bid", async()=>{
//		var bidAmount = web3.toWei(1000, "ether");
//		var minIncrement = web3.toWei(10, "ether");
//		var asdf = web3.toWei(1010, "ether");
		var bidAmount = 1000;
		var minIncrement = 10;

		var result = await token20.bid(auction.address, web3.toWei(bidAmount+minIncrement, "ether"), {from:bidder[2]});
		//var result = await token20.bid(auction.address, asdf, {from:bidder[2]});

		//	await auction.bid(bidAmount+minIncrement, {from:bidder[2]});
//		var result;
//		for(var i = 0; i < 8; i++){
//			result += await auction.bid(auction.address, web3.toWei(bidAmount, "ether"), {from:bidder[i]});
//
//			bidAmount = bidAmount + (minIncrement+1) * i;
//		}
//
//		console.log('result.logs');
//		for(var i = 0; i < result.logs.length; i++){
//			console.log(result.logs[i].event);
//			console.log(result.logs[i].args);
//			console.log();
//		}
	});

	it("token approved check", async()=>{
		var approved2Auction = await token20.allowance(bidder[2], auction.address, {from:manager});
		var approved2Token721= await token20.allowance(bidder[2], token721.address, {from:manager});

		console.log("Auction  : " + web3.fromWei(approved2Auction));
		console.log("Token721 : " + web3.fromWei(approved2Token721));
	});

	it("Resolve", async()=>{
		var endTime = (await latestTime()) + duration.seconds(60);
		await increaseTimeTo(endTime);
		
		var result = await auction.resolve({from:manager});

		console.log('result.logs');
		for(var i = 0; i < result.logs.length; i++){
			console.log(result.logs[i].event);
			console.log(result.logs[i].args);
			console.log();
		}
		// 721 토큰 소유자 변경 확인
//		assert.equal( seller, await token721.ownerOf(token721Id) );
	});

});
