// Privacy-preserving proof of linear transformation: y = W * x
// W: 3x2 matrix (private)
// x: 2-dimensional vector (private)
// y: 3-dimensional vector (public)
//
// This circuit allows a prover to convince a verifier that y is the result of applying
// a secret linear transformation (W) to a secret input (x), without revealing either.
// Only y is public; W and x are private inputs.

/// Performs matrix-vector multiplication: y = W * x
/// W is provided as a 3x2 matrix, flattened into a 6-element array
/// x is a 2-element vector
/// Returns a 3-element output vector
fn linear_transform(w_flat: [Field; 6], x: [Field; 2]) -> [Field; 3] {
    let mut y = [0; 3];
    for i in 0..3 {
        let mut sum = 0;
        for j in 0..2 {
            let idx_w = (i as u32) * 2 + (j as u32); // calculate index for flattened W
            sum += w_flat[idx_w] * x[j];
        }
        y[i] = sum;
    }
    y
}

/// Main entry point for the circuit
/// y: public output (3-element vector)
/// w_flat: private matrix W (flattened 3x2)
/// x: private input vector (2-element)
fn main(
    y: [Field; 3],        // PUBLIC output
    w_flat: [Field; 6],   // PRIVATE matrix W (3x2, flattened)
    x: [Field; 2],        // PRIVATE input vector x
) -> pub [Field; 3] {
    let computed_y = linear_transform(w_flat, x);
    for i in 0..3 {
        assert(computed_y[i] == y[i]);
    }
    y
}

// --- TESTS ---

#[test]
fn test_linear_transform_pass() {
    // W = [[1,2],[3,4],[5,6]]
    let w = [1, 2, 3, 4, 5, 6];
    // x = [10, 20]
    let x = [10, 20];
    // y = [1*10+2*20, 3*10+4*20, 5*10+6*20] = [50, 110, 170]
    let y = [50, 110, 170];

    let result = main(y, w, x);
    assert(result == y);
}

#[test]
fn test_linear_transform_pass_negatives() {
    // W = [[-1,2],[3,-4],[0,6]]
    let w = [-1, 2, 3, -4, 0, 6];
    // x = [5, -8]
    let x = [5, -8];
    // y = [-1*5 + 2*(-8), 3*5 + (-4)*(-8), 0*5 + 6*(-8)] = [ -5 -16, 15+32, 0-48 ] = [-21, 47, -48]
    let y = [-21, 47, -48];

    let result = main(y, w, x);
    assert(result == y);
}

#[test(should_fail)]
fn test_linear_transform_fail_wrong_output() {
    // W = [[1,2],[3,4],[5,6]]
    let w = [1, 2, 3, 4, 5, 6];
    let x = [10, 20];
    let y_wrong = [0, 0, 0]; // Incorrect output

    let result = main(y_wrong, w, x);
    assert(result == y_wrong);
}

#[test(should_fail)]
fn test_linear_transform_fail_wrong_matrix() {
    // W = [[0,0],[0,0],[0,0]] (Incorrect W)
    let w_wrong = [0, 0, 0, 0, 0, 0];
    let x = [10, 20];
    let y = [50, 110, 170]; // Should not match output

    let result = main(y, w_wrong, x);
    assert(result == y);
}

#[test(should_fail)]
fn test_linear_transform_fail_wrong_vector() {
    let w = [1, 2, 3, 4, 5, 6];
    let x_wrong = [0, 0]; // Incorrect x
    let y = [50, 110, 170]; // Should not match output

    let result = main(y, w, x_wrong);
    assert(result == y);
}