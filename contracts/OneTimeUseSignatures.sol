pragma solidity 0.4.18;

import './SignatureChecker.sol';

contract OneTimeUseSignatures is SignatureChecker {
    mapping(bytes32 => bool) public signatureUsed;

    modifier burnSignature(bytes32 messageHash, bytes signature) {
        require(!signatureUsed[keccak256(signature)]);
        require(isSignedByAuthorizedAccount(messageHash, signature));
        _;
    }
}
