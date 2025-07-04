/// Checks whether a private input `x` lies within a public range `[min, max]`.
/// Fails if `x` is less than `min` or greater than `max`.
fn main(x: u32, min: pub u32, max: pub u32) {
    assert(x >= min, "x is below the minimum bound");
    assert(x <= max, "x is above the maximum bound");
}
#[test]
fn test_range_check_pass() {
    let x = 15;
    let min = 10;
    let max = 20;
    main(x, min, max);
}

#[test(should_fail)]
fn test_range_check_fail_below() {
    let x = 5;
    let min = 10;
    let max = 20;
    main(x, min, max);
}

#[test(should_fail)]
fn test_range_check_fail_above() {
    let x = 25;
    let min = 10;
    let max = 20;
    main(x, min, max);
}
