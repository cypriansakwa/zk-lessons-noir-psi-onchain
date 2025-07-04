# noir-zkp-bounds-check

## 🛡️ Overview

This repository demonstrates how to write, prove, and verify a simple **zero-knowledge bounds-checking circuit** in Noir.  
The circuit checks whether a **private input** `x` lies within a **public range** `[min, max]`.

It uses:
- `bb` backend for proof generation
- A Solidity verifier for on-chain verification
- JavaScript and CLI workflows for automation

---

## 🧠 Circuit Logic

The Noir circuit enforces the condition:

```noir
assert(x >= min, "x is below the minimum bound");
assert(x <= max, "x is above the maximum bound");
```
Where:

- `x` is a **private** input
- `min` and `max` are **public** inputs

This ensures that `x` is **within the inclusive range** `[min, max]`.

### Folder Structure:
- `/circuits` – Contains the Noir circuits.
- `/contract` – A Foundry project with:
  - A Solidity verifier contract.
  - A test contract that reads the proof file and verifies it.
- `/js` – JavaScript scripts to:
  - Generate proofs.
  - Save them as JSON files compatible with Solidity.

---


## ✅ Tested With
- **Noir**: `v1.0.0-beta.6`
- **bb**: `v0.84.0`

## 🛠 Installation & Setup

```bash
# Clone the repo and pull submodules (e.g., for bb-solidity)
git submodule update --init --recursive

# Build circuits and generate the Solidity verifier
(cd circuits && ./build.sh)

# Install JavaScript dependencies
(cd js && yarn)
``` 

## 🧪 Proof Generation (JavaScript Workflow)

```bash
# Use bb.js to generate proof and save it to a file
(cd js && yarn generate-proof)

# Run Foundry test to read the generated proof and verify it
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```
## 🔧 Proof Generation (CLI Workflow)

```bash
cd circuits

# Generate witness using nargo
nargo execute

# Generate proof with bb CLI
bb prove -b ./target/noir_zkp_bounds_check.json -w ./target/noir_zkp_bounds_check.gz -o ./target --oracle_hash keccak

# Run Foundry test to verify proof
cd ..
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```

## 🔁 Dual Workflow Support: CLI & JavaScript

This project supports two parallel workflows for generating and verifying proofs:

- ✅ **JavaScript-based workflow** using `bb.js` and automated proof orchestration
- 🔧 **Command-line workflow** using `nargo` and `bb` directly

Choose the one that fits your stack or integration best.

---

## 🏗️ Building the Solidity Verifier

Run the `build.sh` script from the project root:

```bash
./build.sh
```
This will:
- Compile the Noir circuit using `nargo`
- Generate the verification key (`vk`)
- Export the Solidity verifier as `contract/Verifier.sol`





