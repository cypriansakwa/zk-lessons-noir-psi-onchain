fn main(w1: Field, w2: Field, w3: Field, public_modifier: pub Field, required_score: pub Field) {
		let recovery_score = w1 * 2 + w2 * 3 + w3 * 5 + public_modifier;
		
		assert(recovery_score == required_score);
	}

#[test]
fn test_score_pass_case_1() {
    let w1 = 1;
    let w2 = 2;
    let w3 = 3;
    let public_modifier = 4;
    // recovery_score = 1*2 + 2*3 + 3*5 + 4 = 2 + 6 + 15 + 4 = 27
    let required_score = 27;
    main(w1, w2, w3, public_modifier, required_score);
}

#[test]
fn test_score_pass_case_2() {
    let w1 = 0;
    let w2 = 4;
    let w3 = 2;
    let public_modifier = 1;
    // recovery_score = 0*2 + 4*3 + 2*5 + 1 = 0 + 12 + 10 + 1 = 23
    let required_score = 23;
    main(w1, w2, w3, public_modifier, required_score);
}

#[test(should_fail)]
fn test_score_fail_case() {
    let w1 = 1;
    let w2 = 1;
    let w3 = 1;
    let public_modifier = 1;
    // recovery_score = 1*2 + 1*3 + 1*5 + 1 = 2 + 3 + 5 + 1 = 11
    let required_score = 10; // Wrong on purpose
    main(w1, w2, w3, public_modifier, required_score);
}
