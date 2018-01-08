pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import 'zeppelin-solidity/contracts/ECRecovery.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './GameSettings.sol';

contract Pagar is Pausable {
    using SafeMath for uint;

    function Pagar(IGameSettings _settings) public {
        settings = _settings;
    }

    struct Player {
        uint gameId;
        uint deposit;
        address sender;
        bool active;
    }

    IGameSettings public settings;
    mapping(uint => Player) public players;
    uint public nextPlayerId;

    bytes constant SIGNED_MESSAGE_PREFIX = "\x19Ethereum Signed Message:\n32";

    // get the hash that is signed for a game ticket
    function getTicketHash(uint gameId, uint ticketTime) public pure returns (bytes32) {
        return keccak256(gameId, ticketTime);
    }

    // get the hash that is signed for a game ticket
    function getExitHash(uint gameId, uint playerId, uint collected, uint defeatedByPlayerId) public pure returns (bytes32) {
        return keccak256(gameId, playerId, collected, defeatedByPlayerId);
    }

    event LogPlayerJoined(uint indexed gameId, uint deposit, uint playerId);

    // pay a deposit to join the game
    function joinGame(uint gameId, uint ticketTime, bytes permissionSignature) payable whenNotPaused public returns (uint playerId) {
        require(gameId != 0);

        var (minDeposit, maxDeposit, ticketTtl, joinFee) = settings.getGameSettings();

        if (msg.value < joinFee) {
            revert();
        }

        // the deposit is the msg value minus the join fee
        uint deposit = msg.value.sub(joinFee);

        // ticket was issued more than 5 minutes ago
        if (ticketTime < now - ticketTtl) {
            revert();
        }

        if (deposit > maxDeposit || deposit < minDeposit) {
            revert();
        }

        // the id of this player
        playerId = ++nextPlayerId;

        bytes32 messageHash = keccak256(SIGNED_MESSAGE_PREFIX, getTicketHash(gameId, ticketTime));

        address signer = ECRecovery.recover(messageHash, permissionSignature);

        require(signer == owner);

        players[playerId] = Player({
            gameId: gameId,
            deposit: deposit,
            sender: msg.sender,
            active: true
        });

        LogPlayerJoined(gameId, playerId, deposit);

        return playerId;
    }

    event LogPlayerEnd(uint indexed gameId, uint indexed playerId, uint indexed defeatedByPlayerId, uint collected);

    function exitGame(uint gameId, uint playerId, uint collected, uint defeatedByPlayerId, bytes permissionSignature) public whenNotPaused returns (bool success) {
        Player storage player = players[playerId];

        // if the player is not active revert
        if (!player.active) {
            revert();
        }

        // somehow the players are not in the same game
        if (players[defeatedByPlayerId].gameId != player.gameId) {
            revert();
        }

        // check the message is signed by the owner
        bytes32 messageHash = keccak256(SIGNED_MESSAGE_PREFIX, getExitHash(gameId, playerId, collected, defeatedByPlayerId));

        address signer = ECRecovery.recover(messageHash, permissionSignature);

        require(signer == owner);

        // mark the player inactive
        player.active = false;

        // transfer the collected ether to the player
        player.sender.transfer(collected);

        return true;
    }

}