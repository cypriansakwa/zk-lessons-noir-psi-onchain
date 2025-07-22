// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../CyprianVerifierApp.sol"; // 🔁 updated from Starter.sol
import "../Verifier.sol";

contract CyprianVerifierAppTest is Test {
    CyprianVerifierApp public verifierApp; // 🔁 updated type
    HonkVerifier public verifier;
    bytes32[] public publicInputs = new bytes32[](1);

    function setUp() public {
        verifier = new HonkVerifier();
        verifierApp = new CyprianVerifierApp(verifier); // 🔁 updated constructor 
        publicInputs[0] = bytes32(uint256(2));
    }
   function testVerifyProof() public {
    bytes memory proof = vm.readFileBinary("../circuits/target/proof");
    bool result = verifierApp.verifyEqual(proof, publicInputs);
    assert(result);
}
}

