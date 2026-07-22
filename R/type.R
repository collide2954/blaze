blaze_type <- S7::new_class(
  "blaze_type",
  properties = list(
    base = S7::class_character,
    len = S7::class_integer
  )
)

new_base_type <- function(base, len = NULL) {
  blaze_type(base = base, len = if (is.null(len)) integer() else as.integer(len))
}

#' Base type constructors
#'
#' Each constructor returns a `blaze_type` describing an R vector of a single
#' base type, named as [typeof()] reports it. Pass `len` to require an exact
#' length; for example `t_int(1)` is a length-1 integer.
#'
#' @param len Optional exact length the value must have.
#' @return A `blaze_type` object.
#' @name base-types
#' @examples
#' t_int()
#' t_int(1)
#' t_chr()
NULL

#' @rdname base-types
#' @export
t_int <- function(len = NULL) new_base_type("integer", len)

#' @rdname base-types
#' @export
t_dbl <- function(len = NULL) new_base_type("double", len)

#' @rdname base-types
#' @export
t_chr <- function(len = NULL) new_base_type("character", len)

#' @rdname base-types
#' @export
t_lgl <- function(len = NULL) new_base_type("logical", len)

#' @rdname base-types
#' @export
t_cpl <- function(len = NULL) new_base_type("complex", len)

#' @rdname base-types
#' @export
t_raw <- function(len = NULL) new_base_type("raw", len)

#' @rdname base-types
#' @export
t_list <- function(len = NULL) new_base_type("list", len)
