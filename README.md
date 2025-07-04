# noir zkp parametric quadratic

This project demonstrates a foundational concept in Zero-Knowledge Proofs (ZKPs): **proving knowledge of a private input that satisfies a known public relationship — without revealing the input**.

## 🧠 Concept

We define a public output `y` and prove that we know a secret value `x` such that:

$$ y = a x^2 + b x + c $$

where `a`, `b`, and `c` are public parameters and `x` is the private witness.

This is useful in scenarios like:

- Proving compliance with a hidden policy
- Demonstrating possession of preimages in cryptographic commitments
- Verifying constraint satisfaction without revealing the underlying data

## 📦 Circuit Details

The Noir circuit ensures that:
- The prover **knows** an `x`
- Such that the public `y` satisfies the quadratic expression with public coefficients `a`, `b`, and `c`

```noir
/// Proves knowledge of `x` such that:
/// public_y = a * x^2 + b * x + c
fn main(x: Field, a: pub Field, b: pub Field, c: pub Field, public_y: pub Field) {
    let y = a * x * x + b * x + c;
    assert(y == public_y);
}

// Success test: x = 2, a = 3, b = 3, c = 5, public_y = 23 (3*2^2 + 3*2 + 5 = 12 + 6 + 5 = 23)
#[test]
fn test_quadratic_relation_success() {
    let x = 2;
    let a = 3;
    let b = 3;
    let c = 5;
    let public_y = 23;
    main(x, a, b, c, public_y);
}

// Failure test: x = 3, a = 2, b = 3, c = 5, public_y = 16 (should fail, since 2*3^2 + 3*3 + 5 = 18 + 9 + 5 = 32)
#[test(should_fail)]
fn test_quadratic_relation_failure() {
    let x = 3;
    let a = 2;
    let b = 3;
    let c = 5;
    let public_y = 16;
    main(x, a, b, c, public_y);
}
```

## ✅ Example Use Case

A user may want to prove they know a value that satisfies a certain equation — e.g., access level or credential — **without revealing the value itself**.

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
bb prove -b ./target/noir_zkp_parametric_quadratic.json -w target/noir_zkp_parametric_quadratic.gz -o ./target --oracle_hash keccak

# Run Foundry test to verify proof
cd ..
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```