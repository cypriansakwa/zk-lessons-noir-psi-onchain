// Proves knowledge of `x` such that:
/// public_y = a * x^2 + b * x + c
fn main(x: Field, a: pub Field, b: pub Field, c: pub Field, public_y: pub Field) {
    let y = a * x * x + b * x + c;
    assert(y == public_y);
}

#[test]
fn test_quadratic_relation_success() {
    let x = 2;
    let a = 3;
    let b = 3;
    let c = 5;
    let public_y = 23; // 3*2^2 + 3*2 + 5 = 12 + 6 + 5
    main(x, a, b, c, public_y);
}

#[test(should_fail)]
fn test_quadratic_relation_failure() {
    let x = 3;
    let a = 2;
    let b = 3;
    let c = 5;
    let public_y = 16; // Should be 9 + 9 + 5 = 23
    main(x, a, b, c, public_y);
}