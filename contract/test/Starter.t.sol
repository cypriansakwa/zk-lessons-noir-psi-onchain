// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../CyprianVerifierApp.sol";
import "../Verifier.sol";

contract CyprianVerifierAppTest is Test {
    CyprianVerifierApp public verifierApp;
    HonkVerifier public verifier;
    bytes32[] public publicInputs = new bytes32[](4);

    function setUp() public {
        verifier = new HonkVerifier();
        verifierApp = new CyprianVerifierApp(verifier);

        // Set according to your circuit's expected public output!
        publicInputs[0] = bytes32(uint256(58));
        publicInputs[1] = bytes32(uint256(64));
        publicInputs[2] = bytes32(uint256(139));
        publicInputs[3] = bytes32(uint256(154));
    }

    function testVerifyProof() public {
        // Make sure this path matches your proof's actual location and extension.
        bytes memory proof = vm.readFileBinary("../circuits/target/proof");
        console.log("Proof length:", proof.length);

        verifierApp.verifyEqual(proof, publicInputs);
    }
}
