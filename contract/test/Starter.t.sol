// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../CyprianVerifierApp.sol"; // 🔁 updated from Starter.sol
import "../Verifier.sol";

contract CyprianVerifierAppTest is Test {
    CyprianVerifierApp public verifierApp; // 🔁 updated type
    HonkVerifier public verifier;
    bytes32[] public publicInputs = new bytes32[](4);

    function setUp() public {
        verifier = new HonkVerifier();
        verifierApp = new CyprianVerifierApp(verifier); // 🔁 updated constructor 
        publicInputs[0] = bytes32(0x000000000000000000000000000000000000000000000000000000000000003a);
        publicInputs[1] = bytes32(0x0000000000000000000000000000000000000000000000000000000000000040);
        publicInputs[2] = bytes32(0x000000000000000000000000000000000000000000000000000000000000008b);
        publicInputs[3] = bytes32(0x000000000000000000000000000000000000000000000000000000000000009a);
    }

   function testVerifyProof() public {
    bytes memory proof = vm.readFileBinary("../circuits/target/proof");
    bool result = verifierApp.verifyEqual(proof, publicInputs);
    assert(result);
}
}

