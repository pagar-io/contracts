const GameSettings = artifacts.require('GameSettings');

module.exports = function (deployer) {
  deployer.deploy(GameSettings);
};
