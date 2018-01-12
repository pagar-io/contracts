const GameSettings = artifacts.require('GameSettings');
const Game = artifacts.require('Game');
const ECRecovery = artifacts.require('ECRecovery');

module.exports = function (deployer) {
  deployer.deploy(ECRecovery);
  deployer.link(ECRecovery, Game);
  deployer.deploy(Game, GameSettings.address);
};
