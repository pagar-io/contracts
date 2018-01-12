pragma solidity 0.4.18;

import 'zeppelin-solidity/contracts/ECRecovery.sol';
import './SignerHolder.sol';

contract SignatureChecker is SignerHolder {
    bytes constant SIGNED_MESSAGE_PREFIX = "\x19Ethereum Signed Message:\n32";

    mapping(bytes32 => bool) signatureUsed;

    function withPrefix(bytes32 contentHash) public pure returns (bytes32) {
        return keccak256(SIGNED_MESSAGE_PREFIX, contentHash);
    }

    function isSignedByAuthorizedAccount(bytes32 prefixedMessageHash, bytes signature) public view returns (bool) {
        return isSigner(ECRecovery.recover(prefixedMessageHash, signature));
    }

    modifier messageIsSigned(bytes32 messageHash, bytes signature) {
        require(isSignedByAuthorizedAccount(withPrefix(messageHash), signature));
        _;
    }
}
