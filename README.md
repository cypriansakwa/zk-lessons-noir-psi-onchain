# noir-pedersen-bits16

This project demonstrates a robust **Zero-Knowledge Proof (ZKP)** circuit using **Noir** to prove knowledge of a Pedersen commitment. The circuit allows you to prove that you know the values for $x$ (message) and $r$ (blinding factor) such that $C = g^x \cdot h^r$, **without revealing** $x$ or $r$.

---

## 📝 Circuit Description

The circuit computes:

$$
C = g^x \cdot h^r
$$

and enforces:

- `g` and `h` are public generators.
- `x` and `r` are private inputs (the secret committed value and blinding factor).
- `C` is a public output (the Pedersen commitment).

### Circuit Code

```rust
// Exponentiation by binary bits, for 16 bits
fn pow_bits(base: Field, bits: [Field; 16]) -> Field {
    let mut acc = 1;
    let mut power = base;
    for i in 0..16 {
        // Enforce bitness: bits[i] must be 0 or 1
        assert(bits[i] * (bits[i] - 1) == 0);
        // Branchless accumulator update
        acc = acc * (1 - bits[i]) + (acc * power) * bits[i];
        power = power * power;
    }
    acc
}

fn main(
    x_bits: [Field; 16], // secret exponent bits for x (little-endian, private)
    r_bits: [Field; 16], // secret exponent bits for r (little-endian, private)
    g: pub Field,        // public generator g
    h: pub Field,        // public generator h
    C: pub Field         // public commitment
) {
    let g_x = pow_bits(g, x_bits);
    let h_r = pow_bits(h, r_bits);
    assert(g_x * h_r == C);
}

// Helper to convert integer to little-endian bit array
fn int_to_bits_le(n: Field) -> [Field; 16] {
    let mut arr = [0; 16];
    let mut val = n;
    for i in 0..16 {
        let val_int: u32 = val as u32;
        arr[i] = (val_int % 2) as Field;
        val = (val_int / 2) as Field;
    }
    arr
}

#[test]
fn test_pedersen_commitment_pass_1() {
    let x = 5;
    let r = 7;
    let g = 2;
    let h = 3;

    let x_bits = int_to_bits_le(x);
    let r_bits = int_to_bits_le(r);

    let g_x = pow_bits(g, x_bits);
    let h_r = pow_bits(h, r_bits);
    let C = g_x * h_r;

    main(x_bits, r_bits, g, h, C);
}
```

**Inputs:**
- `x_bits` (`[Field; 16]`): The secret value to commit to, as little-endian bits (private).
- `r_bits` (`[Field; 16]`): The secret blinding factor, as little-endian bits (private).
- `g` (`pub Field`): Pedersen generator (public, must be nonzero).
- `h` (`pub Field`): Pedersen generator (public, must be nonzero).
- `C` (`pub Field`): The public Pedersen commitment output.

The main constraint enforced by the circuit is:

$$
C = g^x \cdot h^r
$$

---

## 📁 Project Structure

- `/circuits` — Contains the Noir circuit code and scripts.
- `/contract` — (Optional) Solidity verifier and integration test contract.
- `/js` — (Optional) JavaScript code to generate proof and save as a file.

**Tested with:**  
- Noir >= 1.0.0-beta.6  

---

## 🚀 Installation / Setup

```bash
# Build circuits
cd circuits
nargo build

# Run tests
nargo test
```

---

## 🧪 Testing

Unit tests can be placed inside `src/main.nr` using the `#[test]` attribute.  
Example tests check that the circuit accepts correct commitments and rejects incorrect ones.

---

## ℹ️ Notes

- All arithmetic in the circuit is performed modulo the field prime (as set by Noir).
- Both `g` and `h` must be fixed or agreed upon by all parties and are marked as `pub`.
- `x_bits` and `r_bits` must remain private for the commitment to be hiding.
- This circuit is robust against bad inputs and enforces bitness for all private bits.

---
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
bb prove -b ./target/noir_private_matrix_proof.json -w target/noir_private_matrix_proof.gz -o ./target --oracle_hash keccak

# Run Foundry test to verify proof
cd ..
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```