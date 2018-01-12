const expect = require('chai').expect;

const GameSettings = artifacts.require('GameSettings');

contract('GameSettings', (accounts) => {
  let settings;

  before(async () => {
    settings = await GameSettings.deployed();
  });

  it('is deployed', async () => {
    expect(settings.address).to.be.an('string');
  });
});