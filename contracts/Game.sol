pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/math/Math.sol';
import './KnowsTime.sol';
import './GameSettings.sol';
import './OneTimeUseSignatures.sol';

contract Game is KnowsTime, Pausable, OneTimeUseSignatures {
    using SafeMath for uint;

    function Game(IGameSettings _settings) public {
        settings = _settings;
    }

    struct Player {
        address owner;
        uint gameId;
        uint deposit;
        bool active;
    }

    // the settings are pulled from this contract
    IGameSettings public settings;

    // the players are mapped by id
    mapping(uint => Player) public players;

    // the next player id is incremented
    uint public nextPlayerId;

    // collected fees
    uint public collectedFees;

    // get the hash that is signed for a game ticket
    function getTicketHash(uint gameId, uint deposit, uint ticketTimeSeconds, uint ticketNonce) public pure returns (bytes32) {
        return keccak256(gameId, deposit, ticketTimeSeconds, ticketNonce);
    }

    // get the hash that is signed for a game ticket
    function getExitHash(uint playerId, uint collected, uint defeatedByPlayerId) public pure returns (bytes32) {
        return keccak256(playerId, collected, defeatedByPlayerId);
    }

    function boundedPercentage(uint value, uint percentage, uint min, uint max) public pure returns (uint) {
        return Math.max256(Math.min256(value.mul(percentage).div(100), max), min);
    }

    function calculateFee(uint deposit) view public returns (uint joinFee) {
        // use the settings to configure the behavior of this method
        var (minDeposit, maxDeposit, ticketTtlSeconds, joinFeePercentage, minFee, maxFee) = settings.getGameSettings();

        // calculate the fee as a percentage of the deposit
        joinFee = boundedPercentage(deposit, joinFeePercentage, minFee, maxFee);
    }

    function withdrawFees() public onlyOwner {
        withdrawFees(collectedFees);
    }

    function withdrawFees(uint amount) public onlyOwner {
        require(amount <= collectedFees);
        collectedFees = 0;
        msg.sender.transfer(amount);
    }

    // apply settings and return the resulting receipt
    function applySettings(uint paidWei, uint deposit, uint ticketTimeSeconds) internal view returns (uint joinFee, uint refund) {
        // use the settings to configure the behavior of this method
        var (minDeposit, maxDeposit, ticketTtlSeconds, joinFeePercentage, minFee, maxFee) = settings.getGameSettings();

        // ticket is still valid
        require(ticketTimeSeconds + ticketTtlSeconds > currentTime());

        // invalid deposit amount
        require(deposit >= minDeposit);
        require(deposit <= maxDeposit);

        // calculate the fee as a percentage of the deposit
        joinFee = calculateFee(deposit);

        // less than the total required amount
        require(paidWei >= deposit.add(joinFee));

        // the refund is any excess wei that is sent
        refund = paidWei.sub(deposit).sub(joinFee);
    }
    
    event LogPlayerJoin(address indexed owner, uint indexed gameId, uint playerId, uint deposit, uint joinFee, uint refund);

    // Pay a deposit and join a game
    function joinGame(uint gameId, uint deposit, uint ticketTimeSeconds, uint ticketNonce, bytes signature) payable whenNotPaused burnSignature(getTicketHash(gameId, deposit, ticketTimeSeconds, ticketNonce), signature) public returns (uint) {
        // invalid game id
        require(gameId != 0);

        var (joinFee, refund) = applySettings(msg.value, deposit, ticketTimeSeconds);
        
        uint playerId = addPlayer(gameId, deposit, owner, joinFee, refund);

        collectedFees = collectedFees.add(joinFee);

        // return any excess wei
        if (refund > 0) {
            msg.sender.transfer(refund);
        }

        return playerId;
    }

    function addPlayer(uint gameId, uint deposit, address owner, uint joinFee, uint refund) internal returns (uint) {
        // the id of this player
        uint playerId = ++nextPlayerId;

        players[playerId] = Player({
            gameId: gameId,
            deposit: deposit,
            owner: owner,
            active: true
        });

        LogPlayerJoin(owner, gameId, playerId, deposit, joinFee, refund);

        return playerId;
    }


    event LogPlayerExit(uint indexed gameId, uint indexed playerId, uint indexed defeatedByPlayerId, uint collected);

    function exitGame(uint playerId, uint collected, uint defeatedByPlayerId, bytes signature) public whenNotPaused burnSignature(getExitHash(playerId, collected, defeatedByPlayerId), signature) returns (bool success) {
        Player storage player = players[playerId];
        Player storage victor = players[defeatedByPlayerId];

        // player must be active
        require(player.active);

        // player must be in the same game
        require(player.gameId == victor.gameId);

        // sender of message must be player who also initiated game
        require(player.owner == msg.sender);

        // mark the player inactive
        player.active = false;

        // transfer the collected ether to the player
        player.owner.transfer(player.deposit / 2);
        victor.owner.transfer(player.deposit / 2);

        return true;
    }

}