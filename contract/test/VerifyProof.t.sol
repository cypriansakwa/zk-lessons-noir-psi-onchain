// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../Verifier.sol"; // HonkVerifier

contract VerifyProofTest is Test {
    HonkVerifier public verifier;
    bytes32[] public publicInputs = new bytes32[](1);

    function setUp() public {
        // deployed address from Anvil
        verifier = HonkVerifier(payable(0x7986034F6b0c37D719ae8a04d8Bc935013f77bf5));

        // populate public inputs
        publicInputs[0] = bytes32(uint256(2));
    }

    function testVerifyProof() public {
        bytes memory proof = vm.readFileBinary("../circuits/target/proof");
        bool result = verifier.verify(proof, publicInputs);
        assert(result);
    }
}
