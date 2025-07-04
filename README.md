# ZK Aggregated Credential Score

This project demonstrates a foundational Zero-Knowledge Proof (ZKP) use case:  
**Proving knowledge of private credentials that satisfy a public weighted scoring formula — without revealing the credentials themselves.**

---

## 🧠 Concept

We compute a **recovery score** based on 3 private weights and a public modifier:

```math
recovery\_score = 2 \cdot w_1 + 3 \cdot w_2 + 5 \cdot w_3 + \texttt{public\_modifier}


/// Proves knowledge of private w1, w2, w3 such that:
/// required_score = 2*w1 + 3*w2 + 5*w3 + public_modifier
fn main(w1: Field, w2: Field, w3: Field, public_modifier: pub Field, required_score: pub Field) {
    let recovery_score = w1 * 2 + w2 * 3 + w3 * 5 + public_modifier;
    assert(recovery_score == required_score);
}

// Passing test
#[test]
fn test_score_pass() {
    let w1 = 1;
    let w2 = 2;
    let w3 = 3;
    let public_modifier = 4;
    let required_score = 27;
    main(w1, w2, w3, public_modifier, required_score);
}

// Failing test
#[test(should_fail)]
fn test_score_fail() {
    let w1 = 1;
    let w2 = 1;
    let w3 = 1;
    let public_modifier = 1;
    let required_score = 10; // wrong on purpose
    main(w1, w2, w3, public_modifier, required_score);
}


## ✅ Example Use Case

A user can prove they have private credentials (e.g. access scores, trust levels, or eligibility factors) that meet a public threshold — without disclosing the underlying values.

---

## Project Structure

This repo lets you verify Noir circuits (with the bb backend) using a Solidity verifier.

- `/circuits` — Contains the Noir circuit and build scripts.
- `/contract` — Foundry project with the Solidity verifier and integration test contract.
- `/js` — JS code to generate proof and save as a file.

Tested with Noir >= 1.0.0-beta.6 and bb >= 0.84.0.

### Installation / Setup

```bash
# Foundry
git submodule update

# Build circuits, generate verifier contract
(cd circuits && ./build.sh)

# Install JS dependencies
(cd js && yarn)
```

### Proof Generation in JS

```bash
# Use bb.js to generate proof and save to a file
(cd js && yarn generate-proof)

# Run Foundry test to verify the generated proof
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```

### Proof Generation with bb CLI

```bash
# Generate witness
nargo execute

# Generate proof with keccak hash
bb prove -b ./target/ZK_Aggregated_Credential_Score.json -w target/ZK_Aggregated_Credential_Score.gz -o ./target --oracle_hash keccak

# Run Foundry test to verify proof
cd ..
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```