pragma solidity 0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract SignerHolder is Ownable {
    // addresses that are allowed to sign
    mapping(address => bool) public signers;

    function isSigner(address signer) public constant returns (bool) {
        return signers[signer];
    }

    event LogSignerChanged(address indexed signer, bool isSigner);

    function setSignerStatus(address[] addresses, bool _isSigner) public onlyOwner returns (bool) {
        // iterate through each address, updating their signer status
        for (uint i = 0; i < addresses.length; i++) {
            if (isSigner(addresses[i]) != _isSigner) {
                signers[addresses[i]] = _isSigner;

                LogSignerChanged(addresses[i], _isSigner);
            }
        }

        return true;
    }
}
