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
  switch(type@base,
    any = NULL,
    data.frame = check_frame(value, type),
    factor = check_fct(value, type),
    list_of = check_list_of(value, type),
    union = check_union(value, type),
    class = check_class(value, type),
    check_scalar(value, type)
  )
}

check_scalar <- function(value, type) {
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

check_fct <- function(value, type) {
  if (!is.factor(value)) {
    return(sprintf("expected a factor, got %s", class(value)[1]))
  }
  extra <- setdiff(levels(value), type@levels)
  if (length(extra) > 0L) {
    return(sprintf("unexpected factor levels: %s", paste(extra, collapse = ", ")))
  }
  NULL
}

check_class <- function(value, type) {
  if (!inherits(value, type@class_name)) {
    return(sprintf("expected an object of class `%s`", type@class_name))
  }
  NULL
}

check_list_of <- function(value, type) {
  if (!is.list(value) || is.data.frame(value)) {
    return(sprintf("expected a list, got %s", class(value)[1]))
  }
  element <- type@element[[1]]
  for (i in seq_along(value)) {
    msg <- check_msg(value[[i]], element)
    if (!is.null(msg)) {
      return(sprintf("element %d: %s", i, msg))
    }
  }
  NULL
}

check_union <- function(value, type) {
  for (alt in type@alternatives) {
    if (is.null(check_msg(value, alt))) {
      return(NULL)
    }
  }
  bases <- vapply(type@alternatives, function(a) a@base, character(1))
  sprintf("expected one of: %s", paste(bases, collapse = ", "))
}

check_frame <- function(value, type) {
  if (!is.data.frame(value)) {
    return(sprintf("expected a data frame, got %s", class(value)[1]))
  }
  problems <- character()
  for (col in names(type@columns)) {
    if (!col %in% names(value)) {
      problems <- c(problems, sprintf("missing column `%s`", col))
      next
    }
    col_msg <- check_msg(value[[col]], type@columns[[col]])
    if (!is.null(col_msg)) {
      problems <- c(problems, sprintf("column `%s`: %s", col, col_msg))
    }
  }
  for (inv in type@invariants) {
    ok <- tryCatch(eval(inv, value, enclos = globalenv()), error = function(e) FALSE)
    if (!isTRUE(all(ok, na.rm = TRUE))) {
      problems <- c(
        problems,
        sprintf("row invariant failed: %s", paste(deparse(inv), collapse = " "))
      )
    }
  }
  if (length(problems) == 0L) {
    return(NULL)
  }
  paste0("data frame does not conform:\n", paste0("- ", problems, collapse = "\n"))
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
