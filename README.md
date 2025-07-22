# Noir Matrix Multiplication ZKP Circuit

This project demonstrates a robust **Zero-Knowledge Proof (ZKP)** circuit using **Noir** for proving knowledge of two secret matrices, **A** (2x3) and **B** (3x2), such that their matrix product **C = A × B** is publicly revealed. The circuit allows you to prove that you know the values for A and B such that $C = AB$, **without revealing A or B to the verifier**.

---

## 📝 Circuit Description

### What does the circuit do?

- **Public Input/Output:**
  - `c_flat` (`[Field; 4]`): The result matrix C, flattened as `[C00, C01, C10, C11]` (2x2).
- **Private Inputs:**
  - `a_flat` (`[Field; 6]`): Matrix A, flattened as `[A00, A01, A02, A10, A11, A12]` (2x3).
  - `b_flat` (`[Field; 6]`): Matrix B, flattened as `[B00, B01, B10, B11, B20, B21]` (3x2).

The circuit **asserts** that when A and B are reshaped to their respective dimensions, their product equals C.  
It does **not reveal** A or B to the verifier.

### Key Constraint

$$
C = A \times B
$$

### Example Circuit Code

```rust
fn main(
    c_flat: [Field; 4],     // PUBLIC input/output: Matrix C (flattened 2x2)
    a_flat: [Field; 6],     // PRIVATE input: Matrix A (flattened 2x3)
    b_flat: [Field; 6],     // PRIVATE input: Matrix B (flattened 3x2)
) -> pub [Field; 4] {
    // Unflatten A into 2x3 matrix
    let a = [
        [a_flat[0], a_flat[1], a_flat[2]],
        [a_flat[3], a_flat[4], a_flat[5]],
    ];

    // Unflatten B into 3x2 matrix
    let b = [
        [b_flat[0], b_flat[1]],
        [b_flat[2], b_flat[3]],
        [b_flat[4], b_flat[5]],
    ];

    // Unflatten C into 2x2 matrix (used for assertion)
    let c = [
        [c_flat[0], c_flat[1]],
        [c_flat[2], c_flat[3]],
    ];

    // Matrix multiplication check: C == A * B
    for i in 0..2 {
        for j in 0..2 {
            let mut sum = 0;
            for k in 0..3 {
                sum += a[i][k] * b[k][j];
            }
            assert(sum == c[i][j]);
        }
    }
    c_flat
}
```

---

## 🧪 Testing

The circuit includes tests for passing and failing cases, e.g.:

```rust
#[test]
fn test_matrix_mul_pass_1() {
    let a = [1, 2, 3, 4, 5, 6];
    let b = [7, 8, 9, 10, 11, 12];
    let c = [58, 64, 139, 154];

    let result = main(c, a, b);
    assert(result == c);
}

#[test(should_fail)]
fn test_matrix_mul_fail_1() {
    let a = [1, 2, 3, 4, 5, 6];
    let b = [7, 8, 9, 10, 11, 12];
    let c = [0, 0, 0, 0]; // Incorrect C

    let result = main(c, a, b);
    assert(result == c);
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
bb prove -b ./target/noir_private_matrix_proof.json -w ./target/noir_private_matrix_proof.gz -o ./target --oracle_hash keccak
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
- Only C (the result) is public; A and B remain secret.
- For production, validate all inputs for expected ranges/types.
- Make sure toolchain versions match for proof/verification compatibility.

---

## 💡 Use Cases

Here are a few scenarios where this circuit is valuable:

1. **Privacy-Preserving Machine Learning**  
   Prove that you performed a correct linear transformation or neural network layer without revealing the model weights or input data.

2. **Secure Computation Outsourcing**  
   Convince a client you processed their sensitive data correctly (e.g., confidential statistics, encrypted images) using secret matrices, without leaking proprietary algorithms or data.

3. **Confidential Data Validation**  
   Prove compliance with a data-processing rule (e.g., regulatory check, secure voting) involving matrix multiplication, while keeping the underlying data private.

---

## 🏆 Why Use This Circuit?

Prove you know matrices A and B such that C = AB, **without revealing A or B**.  
Useful for privacy-preserving computations, secure ML, and ZKP research.

---
### 🧭 Ecosystem Attribution

This project is indexed in the [Electric Capital Crypto Ecosystems Map](https://github.com/electric-capital/crypto-ecosystems).

**Source**: Electric Capital Crypto Ecosystems  
**Link**: [https://github.com/electric-capital/crypto-ecosystems](https://github.com/electric-capital/crypto-ecosystems)  
**Logo**: ![Electric Capital Logo](https://avatars.githubusercontent.com/u/44590959?s=200&v=4)

💡 _If you’re working in open source crypto, [submit your repository here](https://github.com/electric-capital/crypto-ecosystems) to be counted._

Thank you for contributing and for reading the contribution guide! ❤️
