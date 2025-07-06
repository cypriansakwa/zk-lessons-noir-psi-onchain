fn pow(base: Field, exp: u16) -> Field {
    // Computes base^exp using binary (square-and-multiply) exponentiation.
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

#[test]
fn test_pedersen_commit_pass_case_one() {
    let message: u16 = 3;
    let blinding: u16 = 5;
    let g: Field = 7;
    let h: Field = 11;

    // Compute commitment: g^message * h^blinding = 7^3 * 11^5
    let expected_commitment: Field = pedersen_commit(message, blinding, g, h);

    main(message, blinding, g, h, expected_commitment);
}

#[test]
fn test_pedersen_commit_pass_case_two() {
    let message: u16 = 2;
    let blinding: u16 = 4;
    let g: Field = 5;
    let h: Field = 13;

    // Compute commitment: 5^2 * 13^4
    let expected_commitment: Field = pedersen_commit(message, blinding, g, h);

    main(message, blinding, g, h, expected_commitment);
}

#[test(should_fail)]
fn test_pedersen_commit_fail_case() {
    let message: u16 = 2;
    let blinding: u16 = 3;
    let g: Field = 5;
    let h: Field = 13;

    // Wrong expected commitment on purpose
    let wrong_commitment: Field = 12345;

    main(message, blinding, g, h, wrong_commitment);
}
