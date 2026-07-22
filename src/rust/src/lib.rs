use extendr_api::prelude::*;

mod check;

/// Name the base type of `value` as `typeof()` reports it.
fn typeof_str(value: &Robj) -> &'static str {
    match value.rtype() {
        Rtype::Integers => "integer",
        Rtype::Doubles => "double",
        Rtype::Strings => "character",
        Rtype::Logicals => "logical",
        Rtype::Complexes => "complex",
        Rtype::Raw => "raw",
        Rtype::List => "list",
        _ => "other",
    }
}

/// Check the base type of `value` against `expected`, returning `NULL` on a
/// match or a message describing the mismatch.
/// @noRd
#[extendr]
fn blaze_check_base(value: Robj, expected: &str) -> Robj {
    match check::base_violation(typeof_str(&value), expected) {
        Some(msg) => msg.into(),
        None => ().into(),
    }
}

/// Check the length of `value` against `[min, max]` bounds (each empty when
/// unset), returning `NULL` on a match or a message describing the mismatch.
/// @noRd
#[extendr]
fn blaze_check_length(value: Robj, min: Vec<i32>, max: Vec<i32>) -> Robj {
    match check::length_violation(value.len(), &min, &max) {
        Some(msg) => msg.into(),
        None => ().into(),
    }
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod blaze;
    fn blaze_check_base;
    fn blaze_check_length;
}
