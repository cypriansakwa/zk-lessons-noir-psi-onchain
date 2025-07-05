# noir_modular_exponentiation

This project demonstrates a simple **Zero-Knowledge Proof (ZKP)** circuit using **Noir** to prove knowledge of a modular exponentiation computation without revealing the base or the exponent.

## 📝 Circuit Description

The circuit computes:

$$\mathrm{result} = \mathrm{base^exponent} \mod modulus$$

The modulus is hardcoded as a private constant inside the circuit.


The modulus is hardcoded as a private constant inside the circuit.

### Circuit Code

```rust
fn mod_exp(base: u32, exponent: u32, modulus: u32) -> u32 {
    let mut result: u32 = 1;
    let mut base_power: u32 = base % modulus;
    let mut exp: u32 = exponent;

    for _ in 0..32 {
        if exp & 1 == 1 {
            result = (result * base_power) % modulus;
        }
        base_power = (base_power * base_power) % modulus;
        exp = exp >> 1;
    }

    result
}

fn main(x: u32, e: u32, y: pub Field) {
    let modulus: u32 = 17;
    let result: u32 = mod_exp(x, e, modulus);
    let result_field: Field = result.into();
    assert(result_field == y);
}
```
- `x`: private base (`u32`)
- `e`: private exponent (`u32`)
- `y`: public expected result (`Field`)

The constraint ensures that:
$$y = x^e \mod 17$$


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
bb prove -b ./target/noir_modular_exponentiation.json -w target/noir_modular_exponentiation.gz -o ./target --oracle_hash keccak

# Run Foundry test to verify proof
cd ..
(cd contract && forge test --optimize --optimizer-runs 5000 --gas-report -vvv)
```