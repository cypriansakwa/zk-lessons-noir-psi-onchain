// Noir circuit for proving C = A * B for A (2x3), B (3x2)

fn matrix_mul(a_flat: [Field; 6], b_flat: [Field; 6]) -> [Field; 4] {
    let mut c_flat = [0; 4];
    for i in 0..2 {
        for j in 0..2 {
            let mut sum = 0;
            for k in 0..3 {
                // Cast indices to u32 for compatibility
                let idx_a = (i as u32) * 3 + (k as u32);
                let idx_b = (k as u32) * 2 + (j as u32);
                sum += a_flat[idx_a] * b_flat[idx_b];
            }
            let idx_c = (i as u32) * 2 + (j as u32);
            c_flat[idx_c] = sum;
        }
    }
    c_flat
}

fn main(
    c_flat: [Field; 4],     // PUBLIC output/input: Matrix C (flattened 2x2)
    a_flat: [Field; 6],     // PRIVATE input: Matrix A (flattened 2x3)
    b_flat: [Field; 6],     // PRIVATE input: Matrix B (flattened 3x2)
) -> pub [Field; 4] {
    let computed_c = matrix_mul(a_flat, b_flat);
    for i in 0..4 {
        assert(computed_c[i] == c_flat[i]);
    }
    c_flat
}

// --- TESTS ---
#[test]
fn test_matrix_mul_pass_1() {
    let a = [1, 2, 3, 4, 5, 6];
    let b = [7, 8, 9, 10, 11, 12];
    let c = [58, 64, 139, 154];

    let result = main(c, a, b);
    assert(result == c);
}

#[test]
fn test_matrix_mul_pass_2() {
    let a = [2, 0, 1, 1, 3, 4];
    let b = [1, 2, 0, 1, 4, 0];
    let c = [6, 4, 17, 5];

    let result = main(c, a, b);
    assert(result == c);
}

#[test(should_fail)]
fn test_matrix_mul_fail_1() {
    let a = [1, 2, 3, 4, 5, 6];
    let b = [7, 8, 9, 10, 11, 12];
    let c = [0, 0, 0, 0]; // Incorrect C

    let result = main(c, a, b);
    assert(result == c);
}

#[test(should_fail)]
fn test_matrix_mul_fail_2() {
    let a = [2, 0, 1, 1, 3, 4];
    let b = [1, 2, 0, 1, 4, 0];
    let c = [1, 1, 1, 1]; // Incorrect C

    let result = main(c, a, b);
    assert(result == c);
}