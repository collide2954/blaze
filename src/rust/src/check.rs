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

#[cfg(test)]
mod tests {
    use super::base_violation;

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
}
