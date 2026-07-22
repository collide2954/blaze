#' Check a value against a type
#'
#' Verifies that `value` conforms to `type`. On a match the value is returned
#' invisibly, so `check()` can sit inline in a pipeline. On a mismatch an error
#' is raised describing what was expected and what was found.
#'
#' @param value A value to check.
#' @param type A `blaze_type`, such as [t_int()] or [t_chr()].
#' @return `value`, invisibly, when it conforms to `type`.
#' @export
#' @examples
#' check(1L, t_int())
check <- function(value, type) {
  if (is.null(value) && type@optional) {
    return(invisible(value))
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
  if (!is.null(msg)) {
    stop(msg, call. = FALSE)
  }
  invisible(value)
}

check_refinements <- function(value, refinements) {
  for (r in refinements) {
    msg <- switch(r$kind,
      nonneg = blaze_check_nonneg(value),
      in_range = blaze_check_range(value, r$min, r$max),
      unique_vals = if (anyDuplicated(value)) "expected unique values" else NULL,
      stop("unknown refinement: ", r$kind)
    )
    if (!is.null(msg)) {
      return(msg)
    }
  }
  NULL
}
