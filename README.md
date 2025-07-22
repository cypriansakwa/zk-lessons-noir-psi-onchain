# Hash-Based Private Set Intersection (PSI)

This circuit allows a prover to demonstrate that the intersection between their private set A and a public set B has a known result (e.g., a specific number of overlapping items), **without revealing the full contents of A**.

This project demonstrates a robust **Zero-Knowledge Proof (ZKP)** circuit using **Noir** for privacy-preserving verification of private set intersection. The circuit allows you to prove, in zero-knowledge, that the intersection between your private set and a public set has a specified cardinality, **without revealing your private set**.

---

## 📝 Circuit Description

### What does the circuit do?

- **Public Input/Output:**
  - `b` (`[Field; 4]`): The public set (4 elements).
  - `expected_count` (`Field`): The expected intersection count.
- **Private Inputs:**
  - `a` (`[Field; 4]`): The private set (4 elements).

The circuit:
1. **Deduplicates** both sets, padding with a sentinel value (`0`).
2. **Hashes** each unique element using Poseidon.
3. **Counts** the number of hashed elements that appear in both sets.
4. **Asserts** the intersection count matches `expected_count`.

**Important:** Inputs must NOT contain the value `0`, which is reserved as a sentinel for padding.  
If your domain allows `0` as a valid input, you must change the sentinel value in the circuit.

### Key Constraint

$$
\text{count} = |\text{dedup}(a) \cap \text{dedup}(b)|
$$

### Example Circuit Code

```rust
mod poseidon;

/// Deduplicates a 4-element array, pads with sentinel (0).
/// NOTE: Inputs must NOT contain 0; 0 is reserved as padding.
fn dedup(input: [Field; 4]) -> ([Field; 4], u32) {
    let mut out = [0; 4];
    let mut count = 0;
    for i in 0..4 {
        let mut seen = 0;
        for j in 0..i {
            seen += if input[i] == input[j] { 1 } else { 0 };
        }
        if seen == 0 {
            out[count] = input[i];
            count += 1;
        }
    }
    (out, count)
}

fn hash_set(set: [Field; 4], n: u32) -> [Field; 4] {
    let mut hashed = [0; 4];
    for i in 0..4 {
        if i < n {
            hashed[i] = poseidon::bn254::hash_1([set[i]]);
        }
    }
    hashed
}

fn count_intersection(a: [Field; 4], n_a: u32, b: [Field; 4], n_b: u32) -> Field {
    let mut count = 0;
    for i in 0..4 {
        if i < n_a {
            let mut found = 0;
            for j in 0..4 {
                if j < n_b {
                    found += if a[i] == b[j] { 1 } else { 0 };
                }
            }
            count += if found > 0 { 1 } else { 0 };
        }
    }
    count
}

/// Main entry point.
/// Asserts that input sets contain no 0s (which is reserved for padding).
fn main(
    a: [Field; 4],          // private set
    b: [Field; 4],          // public set
    expected_count: Field,  // public expected intersection count
) -> pub Field {
    // Enforce: inputs must not contain 0!
    for i in 0..4 {
        assert(a[i] != 0);
        assert(b[i] != 0);
    }

    let (a_dedup, n_a) = dedup(a);
    let (b_dedup, n_b) = dedup(b);

    let hashed_a = hash_set(a_dedup, n_a);
    let hashed_b = hash_set(b_dedup, n_b);

    let count = count_intersection(hashed_a, n_a, hashed_b, n_b);
    assert(count == expected_count);
    count
}
```

---

## 🧪 Testing

The circuit includes tests for passing and failing cases, e.g.:

```rust
#[test]
fn test_intersection_2() {
    let a = [1, 2, 3, 4];
    let b = [3, 4, 5, 6];
    let expected_count = 2;
    let result = main(a, b, expected_count);
    assert(result == expected_count);
}

#[test]
fn test_intersection_0() {
    let a = [1, 2, 3, 4];
    let b = [5, 6, 7, 8];
    let expected_count = 0;
    let result = main(a, b, expected_count);
    assert(result == expected_count);
}

#[test]
fn test_intersection_full_overlap() {
    let a = [9, 10, 11, 12];
    let b = [12, 11, 10, 9];
    let expected_count = 4;
    let result = main(a, b, expected_count);
    assert(result == expected_count);
}

#[test]
fn test_intersection_with_duplicates() {
    let a = [1, 1, 2, 3];
    let b = [2, 2, 3, 4];
    let expected_count = 2;
    let result = main(a, b, expected_count);
    assert(result == expected_count);
}

#[should_fail]
fn test_wrong_count_fails() {
    let a = [1, 2, 3, 4];
    let b = [3, 4, 5, 6];
    let expected_count = 3;
    let _ = main(a, b, expected_count); // This should fail
}
```

---

## 📁 Project Structure

- `/circuits` — Noir circuit code and build scripts.
- `/contract` — (Optional) Solidity verifier and integration tests.
- `/js` — (Optional) JavaScript code to generate proofs and save to file.

**Tested with:**

- Noir >= 1.0.0-beta.6
- Barretenberg CLI (`bb`) 0.84.0
- `@aztec/bb.js` 0.84.0 for JS proof generation

---

## 🚀 Installation / Setup

```bash
# Build circuits
cd circuits
nargo build

# Run circuit tests
nargo test
```

---

## 🧑‍💻 Proof Generation

### JS (bb.js) Approach

```bash
# Install JS dependencies
cd js
yarn install

# Generate proof
yarn generate-proof
```

### CLI Approach

```bash
# Generate witness
nargo execute

# Generate proof with CLI
bb prove -b ./target/noir_psi_proof.json -w target/noir_psi_proof.gz -o ./target --oracle_hash keccak
```

---

## 🛠️ Solidity Verification

You can verify the generated proof using a Solidity contract and Foundry:

```bash
# Run Foundry tests
cd contract
forge test --optimize --optimizer-runs 5000 --gas-report -vvv
```

---

## ℹ️ Notes

- All arithmetic is modulo the Noir circuit field prime.
- Only the expected intersection count and the public set are revealed; the private set remains secret.
- For production, validate all inputs for expected ranges/types.
- Make sure toolchain versions match for proof/verification compatibility.

---

## 💡 Use Cases

Here are a few scenarios where this circuit is valuable:

1. **Private Set Intersection for Web3**  
   Prove, in zero-knowledge, the number of shared items between your private set and a public set without revealing your private set.

2. **Privacy-Preserving Contact Discovery**  
   Find mutual contacts between parties where each party keeps their list private.

3. **Anonymous Membership Verification**  
   Prove you are part of a group (intersection with group list) without revealing your exact identity.

---

## 🏆 Why Use This Circuit?

Prove you share a specified number of items with a public set, **without revealing your private set**.  
Useful for privacy-preserving computations, secure Web3 authentication, and ZKP research.

---
### 🧭 Ecosystem Attribution

This project is indexed in the [Electric Capital Crypto Ecosystems Map](https://github.com/electric-capital/crypto-ecosystems).

**Source**: Electric Capital Crypto Ecosystems  
**Link**: [https://github.com/electric-capital/crypto-ecosystems](https://github.com/electric-capital/crypto-ecosystems)  
**Logo**: ![Electric Capital Logo](https://avatars.githubusercontent.com/u/44590959?s=200&v=4)

💡 _If you’re working in open source crypto, [submit your repository here](https://github.com/electric-capital/crypto-ecosystems) to be counted._

Thank you for contributing and for reading the contribution guide! ❤️
