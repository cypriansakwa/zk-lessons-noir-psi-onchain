fn mod_exp(base: u32, exponent: u32, modulus: u32) -> u32 {
    let mut result: u32 = 1;
    let mut base_power: u32 = base % modulus;
    let mut exp: u32 = exponent;

    for _ in 0..32 { // Supports up to 32-bit exponent
        if exp & 1 == 1 {
            result = (result * base_power) % modulus;
        }
        base_power = (base_power * base_power) % modulus;
        exp = exp >> 1;
    }

    result
}

fn main(base: u32, exponent: u32, modulus: pub u32, expected_result: pub Field) {
    assert(modulus != 0);
    let result: u32 = mod_exp(base, exponent, modulus);
    let result_field: Field = result as Field;
    assert(result_field == expected_result);
}

#[test]
fn test_mod_exp_pass_large_exponent() {
    let base: u32 = 3;
    let exponent: u32 = 29;
    let modulus: u32 = 100;
    let expected_result: Field = 83 as Field; // 3^29 mod 100 = 83
    main(base, exponent, modulus, expected_result);
}

#[test]
fn test_mod_exp_pass_max_exponent() {
    let base: u32 = 2;
    let exponent: u32 = 31; 
    let modulus: u32 = 1000;
    let expected_result: Field = 648 as Field; // 2^31 mod 1000 = 648
    main(base, exponent, modulus, expected_result);
}

#[test]
fn test_mod_exp_pass_big_exponent() {
    let base: u32 = 18;
    let exponent: u32 = 310; 
    let modulus: u32 = 9999;
    let expected_result: Field = 9054 as Field; // 18^310 mod 9999 = 9054
    main(base, exponent, modulus, expected_result);
}

#[test(should_fail)]
fn test_mod_exp_fail_incorrect_expected() {
    let base: u32 = 12;
    let exponent: u32 = 479; 
    let modulus: u32 = 9999;
    let expected_result: Field = 87 as Field; // 12^479 mod 9999 = 1926
    main(base, exponent, modulus, expected_result);
}