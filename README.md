# noir pedersen commitment

This project demonstrates a simple **Zero-Knowledge Proof (ZKP)** circuit using **Noir** to prove knowledge of a Pedersen commitment computation. The circuit allows you to prove that you know the values for `message` and `blinding` such that `commitment = g^message * h^blinding`, **without revealing** `message` or `blinding`.

---

## 📝 Circuit Description

The circuit computes:

$$
\mathrm{commitment} = g^{\mathrm{message}} \cdot h^{\mathrm{blinding}}
$$

- `g` and `h` are public generators.
- `message` and `blinding` are private inputs (the secret committed value and blinding factor).
- `commitment` is a public output.

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
    commitment: pub Field
) {
    let computed_commitment = pedersen_commit(message, blinding, g, h);
    assert(computed_commitment == commitment);
}
```

**Inputs:**
- `message` (`u16`): The secret value to commit to (private).
- `blinding` (`u16`): The secret blinding factor (private).
- `g` (`pub Field`): Pedersen generator (public).
- `h` (`pub Field`): Pedersen generator (public).
- `commitment` (`pub Field`): The public Pedersen commitment output.

The main constraint enforced by the circuit is:

$$
\mathrm{commitment} = g^{\mathrm{message}} \cdot h^{\mathrm{blinding}}
$$

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
bb prove -b ./target/noir_pedersen_commitment.json -w target/noir_pedersen_commitment.gz -o ./target --oracle_hash keccak

# Run Foundry test to verify proof
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```

---

## 🧪 Testing

You can add Noir unit tests for the circuit in `tests/pedersen.t`.  
Example tests check that the circuit accepts correct commitments and rejects incorrect ones.

---

## ℹ️ Notes

- All arithmetic in the circuit is performed modulo the field prime (as set by Noir).
- Both `g` and `h` must be fixed or agreed upon by all parties and must be marked as `pub` to ensure security.
- `message` and `blinding` must remain private for the commitment to be hiding.

---