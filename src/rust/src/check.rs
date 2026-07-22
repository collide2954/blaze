/// Compare an observed base type against the expected one.
///
/// Returns `None` when they match, or a message describing the mismatch.
pub(crate) fn base_violation(observed: &str, expected: &str) -> Option<String> {
    if observed == expected {
        None
    } else {
        Some(format!("expected {expected}, got {observed}"))
    }
}

/// Compare an observed length against an expected exact length.
///
/// `expected` is the type's length constraint: empty means "no constraint",
/// otherwise its first element is the required length. Returns `None` when the
/// length is acceptable, or a message describing the mismatch.
pub(crate) fn length_violation(observed: usize, expected: &[i32]) -> Option<String> {
    match expected.first() {
        None => None,
        Some(&want) => {
            if observed as i64 == i64::from(want) {
                None
            } else {
                Some(format!("expected length {want}, got length {observed}"))
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{base_violation, length_violation};

    #[test]
    fn ok_when_base_matches() {
        assert_eq!(base_violation("integer", "integer"), None);
    }

    #[test]
    fn reports_expected_and_found_on_mismatch() {
        assert_eq!(
            base_violation("character", "integer"),
            Some(String::from("expected integer, got character"))
        );
    }

    #[test]
    fn no_length_constraint_passes() {
        assert_eq!(length_violation(3, &[]), None);
    }

    #[test]
    fn exact_length_matches() {
        assert_eq!(length_violation(1, &[1]), None);
    }

    #[test]
    fn exact_length_mismatch_reports() {
        assert_eq!(
            length_violation(3, &[1]),
            Some(String::from("expected length 1, got length 3"))
        );
    }
}
