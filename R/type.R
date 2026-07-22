blaze_type <- S7::new_class(
  "blaze_type",
  properties = list(
    base = S7::class_character
  )
)

#' Base type constructors
#'
#' Each constructor returns a `blaze_type` describing an R vector of a single
#' base type, named as [typeof()] reports it.
#'
#' @return A `blaze_type` object.
#' @name base-types
#' @examples
#' t_int()
#' t_chr()
NULL

#' @rdname base-types
#' @export
t_int <- function() blaze_type(base = "integer")

#' @rdname base-types
#' @export
t_dbl <- function() blaze_type(base = "double")

#' @rdname base-types
#' @export
t_chr <- function() blaze_type(base = "character")

#' @rdname base-types
#' @export
t_lgl <- function() blaze_type(base = "logical")

#' @rdname base-types
#' @export
t_cpl <- function() blaze_type(base = "complex")

#' @rdname base-types
#' @export
t_raw <- function() blaze_type(base = "raw")

#' @rdname base-types
#' @export
t_list <- function() blaze_type(base = "list")
