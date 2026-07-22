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
        Rtype::Null => "NULL",
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

/// Does `value` contain any R `NA`?
fn any_na(value: &Robj) -> bool {
    if let Some(s) = value.as_integer_slice() {
        s.iter().any(|x| x.is_na())
    } else if let Some(s) = value.as_real_slice() {
        s.iter().any(|x| x.is_na())
    } else if let Some(s) = value.as_logical_slice() {
        s.iter().any(|x| x.is_na())
    } else if let Some(v) = value.as_str_vector() {
        v.iter().any(|x| x.is_na())
    } else {
        false
    }
}

/// Check `value` for a disallowed `NA`, returning `NULL` when acceptable or a
/// message describing the violation.
/// @noRd
#[extendr]
fn blaze_check_na(value: Robj, na_ok: bool) -> Robj {
    match check::na_violation(any_na(&value), na_ok) {
        Some(msg) => msg.into(),
        None => ().into(),
    }
}

/// Check that `value` has no negative elements (ignoring `NA`), returning
/// `NULL` when acceptable or a message describing the violation.
/// @noRd
#[extendr]
fn blaze_check_nonneg(value: Robj) -> Robj {
    let has_negative = if let Some(s) = value.as_integer_slice() {
        s.iter().any(|&x| !x.is_na() && x < 0)
    } else if let Some(s) = value.as_real_slice() {
        s.iter().any(|&x| !x.is_na() && x < 0.0)
    } else {
        false
    };
    match check::nonneg_violation(has_negative) {
        Some(msg) => msg.into(),
        None => ().into(),
    }
}

/// Check that every element of `value` lies in `[min, max]` (ignoring `NA`),
/// returning `NULL` when acceptable or a message describing the violation.
/// @noRd
#[extendr]
fn blaze_check_range(value: Robj, min: f64, max: f64) -> Robj {
    let out_of_range = if let Some(s) = value.as_integer_slice() {
        s.iter()
            .any(|&x| !x.is_na() && (f64::from(x) < min || f64::from(x) > max))
    } else if let Some(s) = value.as_real_slice() {
        s.iter().any(|&x| !x.is_na() && (x < min || x > max))
    } else {
        false
    };
    match check::range_violation(out_of_range, min, max) {
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
    fn blaze_check_na;
    fn blaze_check_nonneg;
    fn blaze_check_range;
}
