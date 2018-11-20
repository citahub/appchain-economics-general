var TokenLock = artifacts.require("./TokenLock.sol");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(TokenLock, [accounts[1], accounts[2]], accounts[3], accounts[4], accounts[5], new Date().getTime(), {
    value: web3.toWei(10, 'ether')
  });
};
