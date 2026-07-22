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

/// Compare an observed length against `[min, max]` bounds.
///
/// Each bound is a slice that is empty when unset, otherwise holds the bound in
/// its first element. When `min` and `max` are both set and equal the length is
/// exact. Returns `None` when the length is acceptable, or a message describing
/// the mismatch.
pub(crate) fn length_violation(observed: usize, min: &[i32], max: &[i32]) -> Option<String> {
    let obs = observed as i64;
    let lo = min.first().copied();
    let hi = max.first().copied();
    if let (Some(l), Some(h)) = (lo, hi) {
        if l == h {
            return if obs == i64::from(l) {
                None
            } else {
                Some(format!("expected length {l}, got length {observed}"))
            };
        }
    }
    if let Some(l) = lo {
        if obs < i64::from(l) {
            return Some(format!("expected length >= {l}, got length {observed}"));
        }
    }
    if let Some(h) = hi {
        if obs > i64::from(h) {
            return Some(format!("expected length <= {h}, got length {observed}"));
        }
    }
    None
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
        assert_eq!(length_violation(3, &[], &[]), None);
    }

    #[test]
    fn exact_length_matches() {
        assert_eq!(length_violation(1, &[1], &[1]), None);
    }

    #[test]
    fn exact_length_mismatch_reports() {
        assert_eq!(
            length_violation(3, &[1], &[1]),
            Some(String::from("expected length 1, got length 3"))
        );
    }

    #[test]
    fn below_min_reports() {
        assert_eq!(
            length_violation(0, &[1], &[]),
            Some(String::from("expected length >= 1, got length 0"))
        );
    }

    #[test]
    fn above_max_reports() {
        assert_eq!(
            length_violation(15, &[0], &[10]),
            Some(String::from("expected length <= 10, got length 15"))
        );
    }

    #[test]
    fn within_bounds_passes() {
        assert_eq!(length_violation(5, &[0], &[10]), None);
    }
}
