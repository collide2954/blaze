blaze_type <- S7::new_class(
  "blaze_type",
  properties = list(
    base = S7::class_character,
    len_min = S7::class_integer,
    len_max = S7::class_integer,
    na_ok = S7::new_property(S7::class_logical, default = FALSE)
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

#' Base type constructors
#'
#' Each constructor returns a `blaze_type` describing an R vector of a single
#' base type, named as [typeof()] reports it. Constrain length with `len` for an
#' exact length, or `min`/`max` for inclusive bounds; for example `t_int(1)` is a
#' length-1 integer and `t_chr(min = 1)` is a non-empty character vector.
#'
#' @param len Optional exact length the value must have.
#' @param min,max Optional inclusive length bounds.
#' @return A `blaze_type` object.
#' @name base-types
#' @examples
#' t_int()
#' t_int(1)
#' t_chr(min = 1)
NULL

#' @rdname base-types
#' @export
t_int <- function(len = NULL, min = NULL, max = NULL) new_base_type("integer", len, min, max)

#' @rdname base-types
#' @export
t_dbl <- function(len = NULL, min = NULL, max = NULL) new_base_type("double", len, min, max)

#' @rdname base-types
#' @export
t_chr <- function(len = NULL, min = NULL, max = NULL) new_base_type("character", len, min, max)

#' @rdname base-types
#' @export
t_lgl <- function(len = NULL, min = NULL, max = NULL) new_base_type("logical", len, min, max)

#' @rdname base-types
#' @export
t_cpl <- function(len = NULL, min = NULL, max = NULL) new_base_type("complex", len, min, max)

#' @rdname base-types
#' @export
t_raw <- function(len = NULL, min = NULL, max = NULL) new_base_type("raw", len, min, max)

#' @rdname base-types
#' @export
t_list <- function(len = NULL, min = NULL, max = NULL) new_base_type("list", len, min, max)

#' Allow `NA` values in a type
#'
#' A `blaze_type` rejects `NA` by default. `t_na_ok()` returns a copy that
#' permits `NA`.
#'
#' @param type A `blaze_type`.
#' @return A `blaze_type` that allows `NA`.
#' @export
#' @examples
#' t_na_ok(t_dbl())
t_na_ok <- function(type) {
  type@na_ok <- TRUE
  type
}
