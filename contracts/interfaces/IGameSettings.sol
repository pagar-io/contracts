pragma solidity ^0.4.18;

// interface for storage of game settings
interface IGameSettings {
    function getGameSettings() public returns (
    // the minimum deposit to join the game
        uint _minDeposit,
    // the maximum deposit allowed when joining the game
        uint _maxDeposit,
    // how long a ticket to join the game is valid
        uint _ticketTtl,
    // the fee paid to join game
        uint _joinFee
    );
}
