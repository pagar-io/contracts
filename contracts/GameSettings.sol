pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './interfaces/IGameSettings.sol';

contract GameSettings is IGameSettings, Ownable {
    function getGameSettings() public constant returns (
        uint _minDeposit,
        uint _maxDeposit,
        uint _ticketTtlSeconds,
        uint _joinFeePercentage,
        uint _minFee,
        uint _maxFee
    ) {
        return (minDeposit, maxDeposit, ticketTtlSeconds, joinFeePercentage, minFee, maxFee);
    }

    uint public maxDeposit;
    uint public minDeposit;
    uint public ticketTtlSeconds;

    uint public joinFeePercentage;
    uint public minFee;
    uint public maxFee;

    function GameSettings(uint _minDeposit, uint _maxDeposit, uint _ticketTtlSeconds, uint _joinFeePercentage, uint _minFee, uint _maxFee) public {
        updateSettings(_minDeposit, _maxDeposit, _ticketTtlSeconds, _joinFeePercentage, _minFee, _maxFee);
    }

    event LogSettingsUpdate(uint minDeposit, uint maxDeposit, uint ticketTtlSeconds, uint joinFeePercentage, uint minFee, uint maxFee);

    function updateSettings(uint _minDeposit, uint _maxDeposit, uint _ticketTtlSeconds, uint _joinFeePercentage, uint _minFee, uint _maxFee) onlyOwner public {
        require(_minDeposit <= _maxDeposit);
        require(_minFee <= _maxFee);
        require(_joinFeePercentage <= 100 && _joinFeePercentage >= 0);

        maxDeposit = _maxDeposit;
        minDeposit = _minDeposit;
        ticketTtlSeconds = _ticketTtlSeconds;
        joinFeePercentage = _joinFeePercentage;
        minFee = _minFee;
        maxFee = _maxFee;

        LogSettingsUpdate(minDeposit, maxDeposit, ticketTtlSeconds, joinFeePercentage, minFee, maxFee);
    }

}
