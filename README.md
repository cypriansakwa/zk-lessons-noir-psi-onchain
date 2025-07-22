# Noir Linear Transformation Proof Circuit

This project demonstrates a robust **Zero-Knowledge Proof (ZKP)** circuit using **Noir** for privacy-preserving verification of a linear transformation. The circuit allows you to prove that you applied a secret linear transformation (matrix multiplication) to secret input data, resulting in a public output, **without revealing the transformation matrix or the input data to the verifier**.

---

## 📝 Circuit Description

### What does the circuit do?

- **Public Input/Output:**
  - `y` (`[Field; 3]`): The output vector, result of the transformation (3-dimensional).
- **Private Inputs:**
  - `w_flat` (`[Field; 6]`): Transformation matrix W, flattened as `[W00, W01, W10, W11, W20, W21]` (3x2).
  - `x` (`[Field; 2]`): Input vector x (2-dimensional).

The circuit **asserts** that when W and x are reshaped to their respective dimensions, their product equals y.  
It does **not reveal** W or x to the verifier.

### Key Constraint

$$
y = W \times x
$$

### Example Circuit Code

```rust
/// Performs matrix-vector multiplication: y = W * x
/// W is provided as a 3x2 matrix, flattened into a 6-element array
/// x is a 2-element vector
/// Returns a 3-element output vector
fn linear_transform(w_flat: [Field; 6], x: [Field; 2]) -> [Field; 3] {
    let mut y = [0; 3];
    for i in 0..3 {
        let mut sum = 0;
        for j in 0..2 {
            let idx_w = (i as u32) * 2 + (j as u32); // calculate index for flattened W
            sum += w_flat[idx_w] * x[j];
        }
        y[i] = sum;
    }
    y
}

/// Main entry point for the circuit
/// y: public output (3-element vector)
/// w_flat: private matrix W (flattened 3x2)
/// x: private input vector (2-element)
fn main(
    y: [Field; 3],        // PUBLIC output
    w_flat: [Field; 6],   // PRIVATE matrix W (3x2, flattened)
    x: [Field; 2],        // PRIVATE input vector x
) -> pub [Field; 3] {
    let computed_y = linear_transform(w_flat, x);
    for i in 0..3 {
        assert(computed_y[i] == y[i]);
    }
    y
}
```

---

## 🧪 Testing

The circuit includes tests for passing and failing cases, e.g.:

```rust
#[test]
fn test_linear_transform_pass() {
    // W = [[1,2],[3,4],[5,6]]
    let w = [1, 2, 3, 4, 5, 6];
    // x = [10, 20]
    let x = [10, 20];
    // y = [1*10+2*20, 3*10+4*20, 5*10+6*20] = [50, 110, 170]
    let y = [50, 110, 170];

    let result = main(y, w, x);
    assert(result == y);
}

#[test(should_fail)]
fn test_linear_transform_fail_wrong_output() {
    let w = [1, 2, 3, 4, 5, 6];
    let x = [10, 20];
    let y_wrong = [0, 0, 0]; // Incorrect output

    let result = main(y_wrong, w, x);
    assert(result == y_wrong);
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
bb prove -b ./target/noir_linear_transform_proof.json -w ./target/noir_linear_transform_proof.gz -o ./target --oracle_hash keccak
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
- Only y (the result) is public; W and x remain secret.
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

Prove you applied a secret linear transformation to secret data, resulting in a public output, **without revealing the transformation or the data itself**.  
Useful for privacy-preserving computations, secure ML, and ZKP research.

---
### 🧭 Ecosystem Attribution

This project is indexed in the [Electric Capital Crypto Ecosystems Map](https://github.com/electric-capital/crypto-ecosystems).

**Source**: Electric Capital Crypto Ecosystems  
**Link**: [https://github.com/electric-capital/crypto-ecosystems](https://github.com/electric-capital/crypto-ecosystems)  
**Logo**: ![Electric Capital Logo](https://avatars.githubusercontent.com/u/44590959?s=200&v=4)

💡 _If you’re working in open source crypto, [submit your repository here](https://github.com/electric-capital/crypto-ecosystems) to be counted._

Thank you for contributing and for reading the contribution guide! ❤️
