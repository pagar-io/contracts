pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './interfaces/IGameSettings.sol';

contract GameSettings is IGameSettings, Ownable {
    function getGameSettings() public returns (
        uint _minDeposit,
        uint _maxDeposit,
        uint _ticketTtl,
        uint _joinFee
    ) {
        return (minDeposit, maxDeposit, ticketTtl, joinFee);
    }

    uint public maxDeposit;
    uint public minDeposit;
    uint public ticketTtl;
    uint public joinFee;

    function GameSettings(uint _minDeposit, uint _maxDeposit, uint _ticketTtl, uint _joinFee) public {
        updateSettings(_minDeposit, _maxDeposit, _ticketTtl, _joinFee);
    }

    event LogSettingsUpdate(uint minDeposit, uint maxDeposit, uint ticketTtl, uint joinFee);

    function updateSettings(uint _minDeposit, uint _maxDeposit, uint _ticketTtl, uint _joinFee) onlyOwner public {
        require(_minDeposit <= _maxDeposit);

        maxDeposit = _maxDeposit;
        minDeposit = _minDeposit;
        ticketTtl = _ticketTtl;
        joinFee = _joinFee;

        LogSettingsUpdate(minDeposit, maxDeposit, ticketTtl, joinFee);
    }

}
