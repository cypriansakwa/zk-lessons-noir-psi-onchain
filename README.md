# Deploying and Verifying Verifier.sol to Sepolia

## Goals for this session

- Compile Noir circuit and produce Solidity verifier
- Deploy verifier contract to Sepolia using Foundry (forge)
- Verify contract source on Sepolia Etherscan
- Interact with the verified contract (Read/Query verify)
- Troubleshooting & best practices

---

## Prerequisites

- Noir toolchain (`noirup`, `nargo`)
- Foundry (`forge`, `cast`) installed and initialized
- Alchemy (or Infura) Sepolia RPC key
- Etherscan API key for Sepolia
- Private key for the deployer account (testnet ETH in Sepolia)
- Basic familiarity with terminal, MetaMask, and Git

---

## 1. Compile Noir circuit (produce verifier)

In your Noir circuit folder:

```bash
# build the circuit and create verifier artifacts
nargo build

# or generate a proof (if you also want proof files)
```
## Typical outputs under `target/`

- `target/honk-verifier-contract/Verifier.sol` — Solidity verifier  
- `target/noir_xxx_proof.json`  
- `target/noir_xxx_proof.gz` — compressed proof (binary)  
- `target/public_inputs` — public inputs  
- `target/vk/` — verification key  

---

## 2. Prepare Foundry project

If not already a Foundry project:

```bash
cd contract
forge init # creates foundry.toml, src/, test/ scaffolding
```
Copy verifier into project root (or `src/`):

```bash
cp ../target/honk-verifier-contract/Verifier.sol ./Verifier.sol

```
Check files:
```bash
ls -la
# Expect Verifier.sol, foundry.toml, script/, test/
```
✅ Key points:

✅ Key points:

- Use `##` for headings to break sections.
- Leave a blank line before and after lists.
- Wrap terminal commands in triple backticks (```) with `bash` for syntax highlighting.
- Use `---` to visually separate sections.

If you want, I can **reformat your entire previous README draft** in this same clean Markdown style so it’s ready for GitHub. Do you want me to do that?

## 3. Deploy script (example) — script/Deploy.s.sol

Use a Foundry deploy script:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../Verifier.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        HonkVerifier verifier = new HonkVerifier(/* constructor args if any */);
        console.log("Verifier deployed at:", address(verifier));
        vm.stopBroadcast();
    }
}
```

Or deploy directly with CLI:

```bash
source .env
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```
## 4. Deployment output (example)
```text
Verifier deployed at: 0xD7148e6Cf725290fdCAbF06519aA1C0031A562c9
Chain 11155111
Estimated gas price: 0.001000178 gwei
Estimated total gas used: 6136249
Contract Address:
0xD7148e6Cf725290fdCAbF06519aA1C0031A562c9
Transactions saved to: broadcast/Deploy.s.sol/11155111/run-latest.json
```
**Note:** Save the deployed contract address for later verification.
## 5. Writing the VerifyProof Test Contract
```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../Verifier.sol"; // HonkVerifier

contract VerifyProofTest is Test {
    HonkVerifier public verifier;
    bytes32[] publicInputs;

    function setUp() public {
        // Deployed address from Anvil or Sepolia
        verifier = HonkVerifier(
            payable(0xD7148e6Cf725290fdCAbF06519aA1C0031A562c9)
        );
                    
        // Populate public inputs
        publicInputs[0] = bytes32(uint256(2));
    }

    function testVerifyProof() public {
        bytes memory proof = vm.readFileBinary("../circuits/target/proof");
        bool result = verifier.verify(proof, publicInputs);
        assert(result);
    }
}
```
**Important Note:** Replace the verifier address with your deployed contract address.

## 6. Checking the Solidity Compiler Version Used

Inspect contract artifact:
```bash
jq keys out/Verifier.sol/HonkVerifier.json

```
Look for compiler information:
```bash
jq '.metadata' out/Verifier.sol/HonkVerifier.json | grep compiler

```
Fallback search:
```bash
grep -R "compiler" out/Verifier.sol/

```
Use the compiler version in verification, e.g., `v0.8.30+commit.73712a01`.

## 7. Verify contract on Sepolia
```bash
forge verify-contract \
0xYOUR_DEPLOYED_ADDRESS \
./Verifier.sol:HonkVerifier \
--chain sepolia \
--compiler-version v0.8.30+commit.73712a01 \
--num-of-optimizations 200 \
--etherscan-api-key $ETHERSCAN_API_KEY
```
Expected response:
```text
Submitted contract for verification: OK
GUID: ...
URL: https://sepolia.etherscan.io/address/0x...
```
## 8. Check verification status (GUID method)
```bash
forge verify-check \
--chain sepolia \
--etherscan-api-key $ETHERSCAN_API_KEY \
varjex1...
```
Expected success:
```text
Contract verification status:
Response: OK
Details: Pass - Verified
```
## 9. Common verification issues & fixes

- **Bytecode mismatch:** ensure exact compiler version.  
- **Metadata mismatch:** use the same artifact from deploy.  
- **Wrong file path:** match `Verifier.sol:HonkVerifier`.  
- **GUID errors:** use full GUID for Sepolia.  

## 10. Interacting with verified contract on Etherscan

1. Open Sepolia Etherscan.  
2. Click **Read Contract** tab.  
3. Connect to Web3 (MetaMask on Sepolia).  
4. Paste proof bytes (hex) and click **Query**.  

> **Note:** `view` functions are gas-free.  

## 11. Preparing proof bytes and public inputs

- `noir_psi_proof.gz` — compressed proof  
- `proof/` or `noir_psi_proof` — raw proof data  
- `public_inputs` — text public inputs  

Convert compressed proof to hex:

```bash
xxd -p noir_psi_proof.gz | tr -d '\n' > proof.hex
cat proof.hex | sed 's/^/0x/' > proof.hex.prefixed
```
## 12. Foundry test to call verifier (example)

// in `test/VerifyProof.t.sol`

```solidity
verifier = HonkVerifier(payable(0xD7148e6C...));
bytes memory proof = vm.readFileBinary("../circuits/target/noir_psi_proof.gz");
bytes32[] publicInputs;
publicInputs[0] = bytes32(uint256(2));
bool ok = verifier.verify(proof, publicInputs);
assert(ok);
```
**Notes:**

- Use `vm.readFileBinary` for binary proof.  
- Address must be contract address, not EOA.  

---

## 13. Troubleshooting interaction errors

- `SyntaxError: Invalid Unicode escape sequence` — paste raw hex (`0x...`).  
- `null` on reading JSON — proof may be binary.  
- `Contract failed to verify` — check compiler commit.  

---

## 14. Best practices and tips

- Keep original `broadcast/.../run-latest.json`.  
- Don’t edit `Verifier.sol` between deploy & verify.  
- Use `.env` for private keys.  
- Pin compiler version in `foundry.toml`.  
- Automate via Makefile or script.  

---

## 15. End-to-end checklist

1. Compile Noir circuit (`nargo build / nargo prove`)  
2. Copy `Verifier.sol` into Foundry project  
3. Confirm compiler settings in `foundry.toml`  
4. Deploy with `forge script --broadcast`  
5. Verify with `forge verify-contract`  
6. Save GUID and use `forge verify-check`  
7. Test locally or via Etherscan Read Contract

  ### 🧭 Ecosystem Attribution

This project is indexed in the [Electric Capital Crypto Ecosystems Map](https://github.com/electric-capital/crypto-ecosystems).

**Source**: Electric Capital Crypto Ecosystems  
**Link**: [https://github.com/electric-capital/crypto-ecosystems](https://github.com/electric-capital/crypto-ecosystems)  
**Logo**: ![Electric Capital Logo](https://avatars.githubusercontent.com/u/44590959?s=200&v=4)

💡 _If you’re working in open source crypto, [submit your repository here](https://github.com/electric-capital/crypto-ecosystems) to be counted._

Thank you for contributing and for reading the contribution guide! ❤️
