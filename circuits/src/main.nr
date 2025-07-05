fn mod_exp(base: u32, exponent: u32, modulus: u32) -> u32 {
    let mut result: u32 = 1;
    let mut base_power: u32 = base % modulus;
    let mut exp: u32 = exponent;

    for _ in 0..32 {  // 32-bit exponent max
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

    // Convert u32 result to Field for assertion
    let result_field: Field = result.into();

    assert(result_field == y);
}

#[test]
    fn test_pass_case_one() {
        let base: u32 = 5;
        let exponent: u32 = 3;
        let result: Field = 6; // 5^3 mod 17 = 125 mod 17 = 6
        main(base, exponent, result);
    }

    #[test]
    fn test_pass_case_two() {
        let base: u32 = 7;
        let exponent: u32 = 2;
        let result: Field = 15; // 7^2 mod 17 = 49 mod 17 = 15
        main(base, exponent, result);
    }

    #[test(should_fail)]
    fn test_fail_case() {
        let base: u32 = 4;
        let exponent: u32 = 2;
        let result: Field = 5; // Incorrect on purpose (4^2 mod 17 = 16 mod 17 = 16)
        main(base, exponent, result);
    }