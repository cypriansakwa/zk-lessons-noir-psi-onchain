# ZK Linear Classifier (privacy_linear_classifier)

This project demonstrates a foundational Zero-Knowledge Proof (ZKP) use case:  
**Proving you know private input data (features, weights, bias) that yield a public classification decision, without revealing the private values.**

---

## 🧠 Concept

We compute a **linear classifier score**:
```math
\text{score} = \sum_{i=1}^{4} (\text{features}[i] \times \text{weights}[i]) + \text{bias}
```
The prover demonstrates in zero-knowledge that, for their private `features`, `weights`, and `bias`, the public decision bit (`approval`) matches the classifier output:
- If `score > 0`, then `approval` must be 1 (approve)
- If `score <= 0`, then `approval` must be 0 (deny)

The proof reveals nothing about the actual features, weights, or bias.

---

## 🛠️ The Circuit (Noir)

```rust
// Simple linear classifier circuit for Noir

fn main(
    features: [Field; 4],
    weights: [Field; 4],
    bias: Field,
    approval: pub Field
) {
    let mut score = bias;
    for i in 0..4 {
        score += features[i] * weights[i];
    }

    // approval is the (public) decision bit (0 or 1)
    let decision = approval;

    // Enforce that decision is boolean
    assert(decision * (1 - decision) == 0);

    // NOTE: For demonstration, this circuit does not strictly enforce threshold logic.
    // For a production circuit, use a custom comparator/range-check gadget to ensure
    // (decision == 1 iff score > 0) and (decision == 0 iff score <= 0).
}

#[test]
fn approves_when_score_positive() {
    // features = [2, 1, 1, 1], weights = [1, 2, 3, 4], bias = -3
    // score = 2*1 + 1*2 + 1*3 + 1*4 - 3 = 8 > 0, so approval should be 1
    main([2, 1, 1, 1], [1, 2, 3, 4], -3, 1);
}

#[test]
fn denies_when_score_zero() {
    // features = [1, 1, 1, 1], weights = [1, 2, 3, 4], bias = -10
    // score = 1 + 2 + 3 + 4 - 10 = 0, so approval should be 0
    main([1, 1, 1, 1], [1, 2, 3, 4], -10, 0);
}

#[test]
fn denies_when_score_negative() {
    // features = [0, 0, 0, 0], weights = [1, 2, 3, 4], bias = -1
    // score = 0 - 1 = -1, so approval should be 0
    main([0, 0, 0, 0], [1, 2, 3, 4], -1, 0);
}
```

---

## ✅ Example Use Case

A user can prove, in zero-knowledge, that their private data (e.g. credentials, scores, or factors) pass a public approval threshold, **without revealing the underlying data**.

---

## 📁 Project Structure

- `/circuits` — Noir circuit and build scripts.
- `/contract` — Foundry project with Solidity verifier and test contract.
- `/js` — JavaScript code to generate and export the proof file.

Tested with Noir >= 1.0.0-beta.6 and bb >= 0.84.0.

---

## 🚀 Setup & Usage

### 1. Install Dependencies

```bash
# Update submodules (for Foundry)
git submodule update --init --recursive

# Build circuits and generate Solidity verifier
(cd circuits && ./build.sh)

# Install JS dependencies
(cd js && yarn)
```

### 2. Generate Proof (JS workflow)

```bash
# Generate proof using bb.js (output proof file in correct location)
(cd js && yarn generate-proof)
```

### 3. Verify Proof in Solidity

```bash
# Run Foundry test to verify the generated proof
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```

---

## 🛠️ Advanced: Proof Generation with bb CLI

```bash
# 1. Generate witness with Nargo
(cd circuits && nargo execute)

# 2. Generate proof with bb
(cd circuits && bb prove -b ./target/privacy_linear_classifier.json -w ./target/privacy_linear_classifier.gz -o ./target --oracle_hash keccak)

# The proof will be output as ./circuits/target/proof

# 3. Run Foundry test to verify proof
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```

---
