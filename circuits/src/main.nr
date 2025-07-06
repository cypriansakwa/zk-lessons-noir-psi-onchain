// Robust Pedersen Commitment Circuit with Range, Consistency, and Safety Checks

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
    strict_range: pub bool,
    require_positive_blinding: pub bool
) {
    // Robustness and safety checks
    assert(min_bound <= max_bound); // Consistent range
    assert(g != 0);                 // Safe generators
    assert(h != 0);

    // Optional: upper limit on message size (e.g., to prevent expensive proofs)
    let max_message_size: u16 = 65535; // Can be adjusted as needed
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

    if require_positive_blinding {
        assert(blinding > 0);
    }
}

#[test]
fn test_pedersen_commit_pass_case_non_strict() {
    let message: u16 = 10;
    let blinding: u16 = 7;
    let g: Field = 5;
    let h: Field = 3;

    let commitment = pedersen_commit(message, blinding, g, h);

    let min_bound: u16 = 5;
    let max_bound: u16 = 15;
    let strict_range: bool = false;
    let require_positive_blinding: bool = false;

    main(
        message,
        blinding,
        g,
        h,
        commitment,
        min_bound,
        max_bound,
        strict_range,
        require_positive_blinding
    );
}

#[test]
fn test_pedersen_commit_pass_case_strict_and_positive_blinding() {
    let message: u16 = 8;
    let blinding: u16 = 1;
    let g: Field = 7;
    let h: Field = 11;

    let commitment = pedersen_commit(message, blinding, g, h);

    let min_bound: u16 = 5;
    let max_bound: u16 = 10;
    let strict_range: bool = true;
    let require_positive_blinding: bool = true;

    main(
        message,
        blinding,
        g,
        h,
        commitment,
        min_bound,
        max_bound,
        strict_range,
        require_positive_blinding
    );
}

#[test(should_fail)]
fn test_pedersen_commit_fail_wrong_commitment() {
    let message: u16 = 6;
    let blinding: u16 = 3;
    let g: Field = 2;
    let h: Field = 5;

    let wrong_commitment: Field = 12345;  // Deliberately incorrect

    let min_bound: u16 = 1;
    let max_bound: u16 = 10;
    let strict_range: bool = false;
    let require_positive_blinding: bool = false;

    main(
        message,
        blinding,
        g,
        h,
        wrong_commitment,
        min_bound,
        max_bound,
        strict_range,
        require_positive_blinding
    );
}
