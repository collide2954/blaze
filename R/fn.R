#' Add a type signature to a function
#'
#' `fn()` wraps a function with runtime type checks. Annotate arguments with
#' `name ~ type` (or `name = type`) and the return value with `.returns = type`;
#' the last unnamed argument is the function to wrap. Arguments left unannotated
#' are not checked, so a signature can be added incrementally.
#'
#' @param ... Argument annotations such as `x ~ t_int(1)`, an optional
#'   `.returns` type, and the function to wrap.
#' @return A function with the same formals that checks its typed arguments on
#'   entry and its result on exit before returning it.
#' @export
#' @examples
#' add <- fn(x ~ t_int(1), y ~ t_int(1), .returns = t_int(1), function(x, y) x + y)
#' add(2L, 3L)
fn <- function(...) {
  dots <- as.list(substitute(list(...)))[-1L]
  nms <- names(dots)
  if (is.null(nms)) nms <- character(length(dots))
  nms[is.na(nms)] <- ""

  arg_type_exprs <- list()
  return_expr <- NULL
  body_expr <- NULL
  for (i in seq_along(dots)) {
    a <- dots[[i]]
    nm <- nms[i]
    if (identical(nm, ".returns")) {
      return_expr <- a
    } else if (is.call(a) && identical(a[[1L]], as.name("~"))) {
      arg_type_exprs[[as.character(a[[2L]])]] <- a[[3L]]
    } else if (nzchar(nm)) {
      arg_type_exprs[[nm]] <- a
    } else {
      body_expr <- a
    }
  }
  if (is.null(body_expr)) {
    stop("fn() requires a function to wrap", call. = FALSE)
  }

  env <- parent.frame()
  fun <- eval(body_expr, env)
  arg_types <- lapply(arg_type_exprs, eval, envir = env)
  return_type <- if (is.null(return_expr)) NULL else eval(return_expr, env)

  wrapper <- function() {
    exec <- environment()
    for (nm in names(arg_types)) {
      check(get(nm, envir = exec), arg_types[[nm]])
    }
    result <- do.call(fun, mget(names(formals(fun)), envir = exec))
    if (!is.null(return_type)) {
      check(result, return_type)
    }
    result
  }
  formals(wrapper) <- formals(fun)
  wrapper
}
