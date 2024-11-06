
const JohnToken = artifacts.require("JohnToken");

const IRouter = artifacts.require("IRouter");
const ITRC20 = artifacts.require("ITRC20");
const TokenLaunchpad = artifacts.require("TokenLaunchpad");

module.exports = function (deployer) {
    // Deploy the contract with the router address as the constructor argument
    deployer.deploy(JohnToken);

    // Deploy the contract with the router address as the constructor argument
    const routerAddress = 'TKzxdSv2FZKQrEqkKVgp5DcwEXBEKMg2Ax'; //SunSwap V2 Router
    const wtrx = 'TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR';          // WTRX              
    deployer.deploy(TokenLaunchpad, routerAddress, wtrx);
};