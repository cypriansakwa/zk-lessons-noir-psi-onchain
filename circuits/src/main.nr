// Noir circuit for proving knowledge of matrices A (2x3) and B (3x2) such that C = A * B.
// PUBLIC INPUT/OUTPUT: c_flat - The result matrix C, flattened as [Field; 4] (2x2).
// PRIVATE INPUTS: a_flat - Matrix A, flattened as [Field; 6] (2x3).
//                 b_flat - Matrix B, flattened as [Field; 6] (3x2).
// The circuit asserts that C == A * B, but does NOT reveal A or B to the verifier.
// For production, ensure input data is validated to be within expected ranges/types.

fn main(
    c_flat: [Field; 4],     // PUBLIC input/output: Matrix C (flattened 2x2)
    a_flat: [Field; 6],     // PRIVATE input: Matrix A (flattened 2x3)
    b_flat: [Field; 6],     // PRIVATE input: Matrix B (flattened 3x2)
) -> pub [Field; 4] {
    // Unflatten A into 2x3 matrix
    let a = [
        [a_flat[0], a_flat[1], a_flat[2]],
        [a_flat[3], a_flat[4], a_flat[5]],
    ];

    // Unflatten B into 3x2 matrix
    let b = [
        [b_flat[0], b_flat[1]],
        [b_flat[2], b_flat[3]],
        [b_flat[4], b_flat[5]],
    ];

    // Unflatten C into 2x2 matrix (used for assertion)
    let c = [
        [c_flat[0], c_flat[1]],
        [c_flat[2], c_flat[3]],
    ];

    // Matrix multiplication check: C == A * B
    for i in 0..2 {
        for j in 0..2 {
            let mut sum = 0;
            for k in 0..3 {
                sum += a[i][k] * b[k][j];
            }
            assert(sum == c[i][j]);
        }
    }

    // Return C as the public output
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