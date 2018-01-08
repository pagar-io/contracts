import {expect} from 'chai';

const GameSettings = artifacts.require('GameSettings');

contract('GameSettings', (accounts) => {
    it('is deployed', () => {
        expect(GameSettings).to.be.an('function');
    });
});