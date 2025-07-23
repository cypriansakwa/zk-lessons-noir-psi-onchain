use poseidon::poseidon::bn254::hash_1;

/// Deduplicates a 4-element array, pads with sentinel (0).
/// NOTE: Inputs must NOT contain 0; 0 is reserved as padding.
fn dedup(input: [Field; 4]) -> ([Field; 4], u32) {
    let mut out = [0; 4];
    let mut count = 0;
    for i in 0..4 {
        let mut seen = 0;
        for j in 0..i {
            seen += if input[i] == input[j] { 1 } else { 0 };
        }
        if seen == 0 {
            out[count] = input[i];
            count += 1;
        }
    }
    (out, count)
}

fn hash_set(set: [Field; 4], n: u32) -> [Field; 4] {
    let mut hashed = [0; 4];
    for i in 0..4 {
        if i < n {
            hashed[i] = hash_1([set[i]]);
        }
    }
    hashed
}

fn count_hashed_intersection(a: [Field; 4], n_a: u32, b: [Field; 4], n_b: u32) -> Field {
    let mut count = 0;
    for i in 0..4 {
        if i < n_a {
            let mut found = 0;
            for j in 0..4 {
                if j < n_b {
                    found += if a[i] == b[j] { 1 } else { 0 };
                }
            }
            count += if found > 0 { 1 } else { 0 };
        }
    }
    count
}

/// Main entry point.
/// Asserts that input sets contain no 0s (which is reserved for padding).
fn main(
    a: [Field; 4],
    b: [Field; 4],
    expected_count: Field,
) -> pub Field {
    // Strictly enforce that 0 is not a valid input
    for i in 0..4 {
        assert(a[i] != 0);
        assert(b[i] != 0);
    }

    let (a_dedup, n_a) = dedup(a);
    let (b_dedup, n_b) = dedup(b);

    let hashed_a = hash_set(a_dedup, n_a);
    let hashed_b = hash_set(b_dedup, n_b);

    let count = count_hashed_intersection(hashed_a, n_a, hashed_b, n_b);

    assert(count == expected_count);

    count
}

#[test]
fn test_intersection_2() {
    let a = [1, 2, 3, 4];
    let b = [3, 4, 5, 6];
    let expected_count = 2;
    let result = main(a, b, expected_count);
    assert(result == expected_count);
}

#[test]
fn test_intersection_0() {
    let a = [1, 2, 3, 4];
    let b = [5, 6, 7, 8];
    let expected_count = 0;
    let result = main(a, b, expected_count);
    assert(result == expected_count);
}

#[test]
fn test_intersection_full_overlap() {
    let a = [9, 10, 11, 12];
    let b = [12, 11, 10, 9];
    let expected_count = 4;
    let result = main(a, b, expected_count);
    assert(result == expected_count);
}

#[test]
fn test_intersection_with_duplicates() {
    let a = [1, 1, 2, 3];
    let b = [2, 2, 3, 4];
    let expected_count = 2;
    let result = main(a, b, expected_count);
    assert(result == expected_count);
}

#[test(should_fail)]
fn test_wrong_count_fails() {
    let a = [1, 2, 3, 4];
    let b = [3, 4, 5, 6];
    let expected_count = 3;
    let _ = main(a, b, expected_count); // This should fail
}