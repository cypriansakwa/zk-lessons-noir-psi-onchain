// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Author: Dr. Cyprian Sakwa
// Date: 2025-07-04
// Description: Custom zk-SNARK verification contract for QuantumVault or related applications.
// License: Open-source under MIT License.

import "./Verifier.sol";

contract CyprianVerifierApp {
    HonkVerifier public verifier;
    uint256 public verifiedCount;

    event ProofVerified(address indexed by, uint256 newCount);

    constructor(HonkVerifier _verifier) {
        verifier = _verifier;
    }

    function getVerifiedCount() public view returns (uint256) {
        return verifiedCount;
    }

    function verifyEqual(bytes calldata proof, bytes32[] calldata publicInputs) public returns (bool) {
        bool proofResult = verifier.verify(proof, publicInputs);
        require(proofResult, "Proof is not valid");

        verifiedCount++;
        emit ProofVerified(msg.sender, verifiedCount);
        return proofResult;
    }
}
