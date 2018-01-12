pragma solidity ^0.4.18;

// interface for storage of game settings
interface IGameSettings {
    function getGameSettings() public constant returns (
    // the minimum deposit to join the game
        uint _minDeposit,
    // the maximum deposit allowed when joining the game
        uint _maxDeposit,
    // how long a ticket to join the game is valid
        uint _ticketTtlSeconds,
    // the fee paid to join game as a percentage of the deposit
        uint _joinFeePercentage,
    // the minimum fee paid in wei
        uint _minFee,
    // the maximum fee paid in wei
        uint _maxFee
    );
}
