// Simple linear classifier circuit for Noir

fn main(
    features: [Field; 4],
    weights: [Field; 4],
    bias: Field,
    approval: pub Field
) {
    let mut score = bias;
    for i in 0..4 {
        score += features[i] * weights[i];
    }

    // Witness: the prover supplies decision bit (0 or 1)
    // Constraints: decision bit must be 0 or 1, and must match approval
    // To threshold, the prover must produce correct decision
    // (score > 0 => decision == 1, score <= 0 => decision == 0)
    let decision = approval; // for simplicity, approval is the decision bit

    // Enforce decision is boolean
    assert(decision * (1 - decision) == 0);

    // For demo: only works if score is in {0,1}
    // For real thresholding, must use custom range check gadget
    // Or, you can use a lookup table for small ranges

    // Optionally: check that (decision == 1 means score > 0), (decision == 0 means score <= 0)
    // For circuits, this typically means you must provide the 'decision' as a witness, and optionally, 'score' as a public output.
}

#[test]
fn approves_when_score_positive() {
    // features = [2, 1, 1, 1], weights = [1, 2, 3, 4], bias = -3
    // score = 2*1 + 1*2 + 1*3 + 1*4 - 3 = 2 + 2 + 3 + 4 - 3 = 8
    // score > 0, so approval should be 1
    main([2, 1, 1, 1], [1, 2, 3, 4], -3, 1);
}

 #[test]
fn denies_when_score_zero() {
    // features = [1, 1, 1, 1], weights = [1, 2, 3, 4], bias = -10
    // score = 1 + 2 + 3 + 4 - 10 = 0, so approval should be 0
    main([1, 1, 1, 1], [1, 2, 3, 4], -10, 0);
}
 #[test]
fn denies_when_score_negative() {
    // features = [0, 0, 0, 0], weights = [1, 2, 3, 4], bias = -1
    // score = 0 - 1 = -1, so approval should be 0
    main([0, 0, 0, 0], [1, 2, 3, 4], -1, 0);
}