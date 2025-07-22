// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../CyprianVerifierApp.sol"; // 🔁 updated from Starter.sol
import "../Verifier.sol";

contract CyprianVerifierAppTest is Test {
    CyprianVerifierApp public verifierApp; // 🔁 updated type
    HonkVerifier public verifier;
    bytes32[] public publicInputs = new bytes32[](3);

    function setUp() public {
        verifier = new HonkVerifier();
        verifierApp = new CyprianVerifierApp(verifier); // 🔁 updated constructor 
        publicInputs[0] = bytes32(0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffffec);
        publicInputs[1] = bytes32(0x000000000000000000000000000000000000000000000000000000000000002f);
        publicInputs[2] = bytes32(0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffffd1);
    }
   function testVerifyProof() public {
    bytes memory proof = vm.readFileBinary("../circuits/target/proof");
    bool result = verifierApp.verifyEqual(proof, publicInputs);
    assert(result);
}
}

