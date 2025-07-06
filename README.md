# zkp-pedersen-range-safe

This project demonstrates a robust **Zero-Knowledge Proof (ZKP)** circuit using **Noir** to prove knowledge of a Pedersen commitment with safety and range checks. The circuit allows you to prove that you know the values for `message` and `blinding` such that `commitment = g^message * h^blinding`, **without revealing** `message` or `blinding`, and ensures your inputs are in a safe, user-defined range.

---

## 📝 Circuit Description

The circuit computes:

$$
\mathrm{commitment} = g^{\mathrm{message}} \cdot h^{\mathrm{blinding}}
$$

and enforces:

- `g` and `h` are public generators and **must not be zero**.
- `message` and `blinding` are private inputs (the secret committed value and blinding factor).
- `commitment` is a public output.
- The `message` is **provably in a user-defined range** (`min_bound` and `max_bound`), with optional strictness.
- Optionally, the `blinding` can be enforced to be strictly positive.
- The bounds themselves are checked for consistency.

### Circuit Code

```rust
fn pow(base: Field, exp: u16) -> Field {
    let mut result = 1;
    let mut acc = base;
    for i in 0..16 {
        if ((exp >> i) & 1) == 1 {
            result *= acc;
        }
        acc *= acc;
    }
    result
}

/// Computes a Pedersen commitment: g^message * h^blinding
fn pedersen_commit(message: u16, blinding: u16, g: Field, h: Field) -> Field {
    let gm = pow(g, message);
    let hr = pow(h, blinding);
    gm * hr
}

fn main(
    message: u16,
    blinding: u16,
    g: pub Field,
    h: pub Field,
    commitment: pub Field,
    min_bound: pub u16,
    max_bound: pub u16,
    strict_range: pub bool,              // If true, use strict inequalities for range
    require_positive_blinding: pub bool  // If true, enforce blinding > 0
) {
    // Robustness and safety checks
    assert(min_bound <= max_bound); // Consistent range
    assert(g != 0);                 // Safe generators
    assert(h != 0);

    // Optional: upper limit on message size (example: 65535)
    let max_message_size: u16 = 65535;
    assert(message <= max_message_size);

    let computed_commitment = pedersen_commit(message, blinding, g, h);
    assert(computed_commitment == commitment);

    // Range proof
    if strict_range {
        assert(message > min_bound);
        assert(message < max_bound);
    } else {
        assert(message >= min_bound);
        assert(message <= max_bound);
    }

    // Optionally require positive blinding
    if require_positive_blinding {
        assert(blinding > 0);
    }
}
```

**Inputs:**
- `message` (`u16`): The secret value to commit to (private).
- `blinding` (`u16`): The secret blinding factor (private).
- `g` (`pub Field`): Pedersen generator (public, must be nonzero).
- `h` (`pub Field`): Pedersen generator (public, must be nonzero).
- `commitment` (`pub Field`): The public Pedersen commitment output.
- `min_bound`/`max_bound` (`pub u16`): Range for the message (public).
- `strict_range` (`pub bool`): Use strict inequalities for range proof.
- `require_positive_blinding` (`pub bool`): Enforce blinding > 0.

The main constraints enforced by the circuit are:

$$
\mathrm{commitment} = g^{\mathrm{message}} \cdot h^{\mathrm{blinding}}
$$

And that the input values are in a safe, consistent range.

---

## 📁 Project Structure

- `/circuits` — Contains the Noir circuit and build scripts.
- `/contract` — Foundry project with the Solidity verifier and integration test contract.
- `/js` — JavaScript code to generate proof and save as a file.

**Tested with:**  
- Noir >= 1.0.0-beta.6  
- bb >= 0.84.0

---

## 🚀 Installation / Setup

```bash
# Update Foundry submodules
git submodule update

# Build circuits and generate the verifier contract
(cd circuits && ./build.sh)

# Install JS dependencies
(cd js && yarn)
```

---

## 🛠️ Proof Generation in JavaScript

```bash
# Use bb.js to generate proof and save to a file
(cd js && yarn generate-proof)

# Run Foundry test to verify the generated proof
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```

---

## 🛠️ Proof Generation with bb CLI

```bash
# Generate witness
nargo execute

# Generate proof with keccak hash
bb prove -b ./target/zkp_pedersen_range_safe.json -w target/zkp_pedersen_range_safe.gz -o ./target --oracle_hash keccak

# Run Foundry test to verify proof
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```

---

## 🧪 Testing

You can add Noir unit tests for the circuit in `tests/pedersen.t`.  
Example tests check that the circuit accepts correct commitments, rejects bad ranges, and handles edge cases like zero generators.

---

## ℹ️ Notes

- All arithmetic in the circuit is performed modulo the field prime (as set by Noir).
- Both `g` and `h` must be fixed or agreed upon by all parties and must be marked as `pub` to ensure security.
- `message` and `blinding` must remain private for the commitment to be hiding.
- This circuit is robust against bad input ranges, zero generators, and (optionally) unsafe blinding.

---