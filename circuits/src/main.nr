// Exponentiation by binary bits, for 16 bits
fn pow_bits(base: Field, bits: [Field; 16]) -> Field {
    let mut acc = 1;
    let mut power = base;
    for i in 0..16 {
        assert(bits[i] * (bits[i] - 1) == 0);
        acc = acc * (1 - bits[i]) + (acc * power) * bits[i];
        power = power * power;
    }
    acc
}

fn main(
    x_bits: [Field; 16],
    r_bits: [Field; 16],
    g: pub Field,
    h: pub Field,
    C: pub Field
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

#[test]
fn test_pedersen_commitment_pass_2() {
    let x = 1;
    let r = 15;
    let g = 4;
    let h = 5;

    let x_bits = int_to_bits_le(x);
    let r_bits = int_to_bits_le(r);

    let g_x = pow_bits(g, x_bits);
    let h_r = pow_bits(h, r_bits);
    let C = g_x * h_r;

    main(x_bits, r_bits, g, h, C);
}

#[test(should_fail)]
fn test_pedersen_commitment_fail() {
    let x = 2;
    let r = 3;
    let g = 6;
    let h = 7;

    let x_bits = int_to_bits_le(x);
    let r_bits = int_to_bits_le(r);

    let g_x = pow_bits(g, x_bits);
    let h_r = pow_bits(h, r_bits);
    let C = g_x * h_r + 1; // Intentionally wrong

    main(x_bits, r_bits, g, h, C);
}