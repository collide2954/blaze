#' Check a value against a type
#'
#' Verifies that `value` conforms to `type`. On a match the value is returned
#' invisibly, so `check()` can sit inline in a pipeline. On a mismatch an error
#' is raised describing what was expected and what was found.
#'
#' `type` is written with the blaze type vocabulary (see [type()]); for example
#' `check(x, int() |> between(0, 1))`. A `blaze_type` built with [type()] may be
#' passed instead.
#'
#' @param value A value to check.
#' @param type A type expression such as `int(1)`, or a `blaze_type`.
#' @return `value`, invisibly, when it conforms to `type`.
#' @export
#' @examples
#' check(1L, int(1))
check <- function(value, type) {
  spec <- eval(substitute(type), type_vocab, enclos = parent.frame())
  check_value(value, spec)
}

check_value <- function(value, type) {
  msg <- check_msg(value, type)
  if (!is.null(msg)) {
    stop(msg, call. = FALSE)
  }
  invisible(value)
}

check_msg <- function(value, type) {
  if (is.null(value) && type@optional) {
    return(NULL)
  }
  if (identical(type@base, "data.frame")) {
    return(check_frame(value, type))
  }
  msg <- blaze_check_base(value, type@base)
  if (is.null(msg)) {
    msg <- blaze_check_length(value, type@len_min, type@len_max)
  }
  if (is.null(msg)) {
    msg <- blaze_check_na(value, type@na_ok)
  }
  if (is.null(msg)) {
    msg <- check_refinements(value, type@refinements)
  }
  msg
}

check_frame <- function(value, type) {
  if (!is.data.frame(value)) {
    return(sprintf("expected a data frame, got %s", class(value)[1]))
  }
  for (col in names(type@columns)) {
    if (!col %in% names(value)) {
      return(sprintf("missing column `%s`", col))
    }
    col_msg <- check_msg(value[[col]], type@columns[[col]])
    if (!is.null(col_msg)) {
      return(sprintf("column `%s`: %s", col, col_msg))
    }
  }
  for (inv in type@invariants) {
    ok <- tryCatch(eval(inv, value, enclos = globalenv()), error = function(e) FALSE)
    if (!isTRUE(all(ok, na.rm = TRUE))) {
      return(sprintf("row invariant failed: %s", paste(deparse(inv), collapse = " ")))
    }
  }
  NULL
}

check_refinements <- function(value, refinements) {
  for (r in refinements) {
    msg <- switch(r$kind,
      nonneg = blaze_check_nonneg(value),
      in_range = blaze_check_range(value, r$min, r$max),
      unique_vals = if (anyDuplicated(value)) "expected unique values" else NULL,
      regex = refine_regex(value, r$pattern),
      nchar_between = refine_nchar(value, r$min, r$max),
      stop("unknown refinement: ", r$kind)
    )
    if (!is.null(msg)) {
      return(msg)
    }
  }
  NULL
}

refine_regex <- function(value, pattern) {
  if (all(grepl(pattern, value[!is.na(value)]))) {
    NULL
  } else {
    sprintf("expected values matching %s", pattern)
  }
}

refine_nchar <- function(value, min, max) {
  lens <- nchar(value[!is.na(value)])
  if (any(lens < min | lens > max)) {
    sprintf("expected string lengths in [%d, %d]", min, max)
  } else {
    NULL
  }
}
