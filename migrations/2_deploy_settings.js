const GameSettings = artifacts.require('GameSettings');
const constants = require('./util/constants');

module.exports = function (deployer) {
  deployer.deploy(
    GameSettings,
    constants.minDeposit, constants.maxDeposit,
    constants.ticketTtlSeconds,
    constants.joinFeePercentage, constants.minFee, constants.maxFee
  );
};
