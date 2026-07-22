blaze_type <- S7::new_class(
  "blaze_type",
  properties = list(
    base = S7::class_character,
    len_min = S7::class_integer,
    len_max = S7::class_integer,
    na_ok = S7::new_property(S7::class_logical, default = FALSE),
    optional = S7::new_property(S7::class_logical, default = FALSE),
    refinements = S7::class_list,
    columns = S7::class_list
  )
)

new_base_type <- function(base, len = NULL, min = NULL, max = NULL) {
  if (!is.null(len)) {
    min <- len
    max <- len
  }
  blaze_type(
    base = base,
    len_min = if (is.null(min)) integer() else as.integer(min),
    len_max = if (is.null(max)) integer() else as.integer(max)
  )
}

# Base type constructors. These are not exported; they are made available under
# terse names inside fn(), check(), and type() via `type_vocab` below.
t_int <- function(len = NULL, min = NULL, max = NULL) new_base_type("integer", len, min, max)
t_dbl <- function(len = NULL, min = NULL, max = NULL) new_base_type("double", len, min, max)
t_chr <- function(len = NULL, min = NULL, max = NULL) new_base_type("character", len, min, max)
t_lgl <- function(len = NULL, min = NULL, max = NULL) new_base_type("logical", len, min, max)
t_cpl <- function(len = NULL, min = NULL, max = NULL) new_base_type("complex", len, min, max)
t_raw <- function(len = NULL, min = NULL, max = NULL) new_base_type("raw", len, min, max)
t_list <- function(len = NULL, min = NULL, max = NULL) new_base_type("list", len, min, max)

t_na_ok <- function(type) {
  type@na_ok <- TRUE
  type
}

t_opt <- function(type) {
  type@optional <- TRUE
  type
}

nonneg <- function(type) {
  type@refinements <- c(type@refinements, list(list(kind = "nonneg")))
  type
}

in_range <- function(type, min, max) {
  type@refinements <- c(
    type@refinements,
    list(list(kind = "in_range", min = min, max = max))
  )
  type
}

unique_vals <- function(type) {
  type@refinements <- c(type@refinements, list(list(kind = "unique_vals")))
  type
}

regex <- function(type, pattern) {
  type@refinements <- c(type@refinements, list(list(kind = "regex", pattern = pattern)))
  type
}

nchar_between <- function(type, min, max) {
  type@refinements <- c(
    type@refinements,
    list(list(kind = "nchar_between", min = as.integer(min), max = as.integer(max)))
  )
  type
}

# A data-frame schema. Column type expressions evaluate in the same vocabulary,
# so `...` already holds the built column types.
frame <- function(...) {
  blaze_type(base = "data.frame", columns = list(...))
}

# The type vocabulary. Terse names resolve to the constructors above only when a
# type expression is evaluated by fn(), check(), or type(), so they never clash
# with user or package bindings at the top level.
type_vocab <- list(
  int = t_int, dbl = t_dbl, chr = t_chr, lgl = t_lgl,
  cpl = t_cpl, raw = t_raw, lst = t_list,
  na_ok = t_na_ok, opt = t_opt,
  nonneg = nonneg, between = in_range, matches = regex,
  unique_vals = unique_vals, nchar_between = nchar_between,
  frame = frame
)

#' The blaze type vocabulary
#'
#' blaze types are written with a small vocabulary that is available inside
#' [fn()], [check()], and `type()` — never as top-level functions, so the terse
#' names never clash with base R or other packages. `type()` evaluates a type
#' expression and returns the resulting `blaze_type`, for building a reusable
#' type outside those contexts.
#'
#' Base types describe a vector of one base type, named as [typeof()] reports it:
#' `int()`, `dbl()`, `chr()`, `lgl()`, `cpl()`, `raw()`, `lst()`. Each accepts
#' `len` for an exact length or `min`/`max` for inclusive length bounds.
#'
#' Modifiers relax the defaults: `na_ok()` permits `NA`, `opt()` permits `NULL`.
#'
#' Refinements add element-wise constraints, composed with the pipe: `nonneg()`,
#' `between(min, max)`, `matches(pattern)`, `unique_vals()`,
#' `nchar_between(min, max)`.
#'
#' A data-frame schema is a type too: `frame(id = int(), age = int() |> nonneg())`
#' checks that a value is a data frame carrying the named columns, each
#' conforming to its column type.
#'
#' Use [blaze_types()] to list the vocabulary.
#'
#' @param expr A type expression such as `int() |> between(0, 1)`.
#' @return A `blaze_type`.
#' @aliases int dbl chr lgl cpl raw lst na_ok opt nonneg between matches
#'   unique_vals nchar_between frame
#' @export
#' @examples
#' pos_int <- type(int() |> nonneg())
#' check(5L, int(1))
type <- function(expr) {
  eval(substitute(expr), type_vocab, enclos = parent.frame())
}

#' List the blaze type vocabulary
#'
#' @return A character vector of the available type, modifier, and refinement
#'   names.
#' @seealso [type()]
#' @export
#' @examples
#' blaze_types()
blaze_types <- function() {
  sort(names(type_vocab))
}
