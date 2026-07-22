#' Define a typed function
#'
#' `fn()` is a drop-in for `function()` that adds runtime type checks. Declare
#' each argument as `name = type` and give the body as the final, unnamed
#' argument; use `.returns = type` for the result. An argument whose value is a
#' `blaze_type` is checked and becomes required; any other `name = value` is an
#' ordinary default on an unchecked argument, so a signature can be typed
#' incrementally.
#'
#' @param ... Argument declarations such as `x = t_int(1)`, an optional
#'   `.returns` type, and the body expression as the final unnamed argument.
#' @return A function that checks its typed arguments on entry and its result on
#'   exit before returning it.
#' @export
#' @examples
#' add <- fn(x = int(1), y = int(1), x + y)
#' add(2L, 3L)
fn <- function(...) {
  dots <- as.list(substitute(list(...)))[-1L]
  nms <- names(dots)
  if (is.null(nms)) nms <- character(length(dots))
  nms[is.na(nms)] <- ""

  return_expr <- NULL
  body_expr <- NULL
  arg_exprs <- list()
  for (i in seq_along(dots)) {
    a <- dots[[i]]
    nm <- nms[i]
    if (identical(nm, ".returns")) {
      return_expr <- a
    } else if (nzchar(nm)) {
      arg_exprs[[nm]] <- a
    } else {
      body_expr <- a
    }
  }
  if (is.null(body_expr)) {
    stop("fn() requires a body expression as its final argument", call. = FALSE)
  }

  env <- parent.frame()

  arg_types <- list()
  fmls <- list()
  for (nm in names(arg_exprs)) {
    value <- tryCatch(eval(arg_exprs[[nm]], type_vocab, enclos = env), error = function(e) NULL)
    if (!is.null(value) && S7::S7_inherits(value, blaze_type)) {
      arg_types[[nm]] <- value
      fmls[nm] <- list(quote(expr = ))
    } else {
      fmls[nm] <- list(arg_exprs[[nm]])
    }
  }
  return_type <- if (is.null(return_expr)) NULL else eval(return_expr, type_vocab, enclos = env)

  fun <- as.function(c(fmls, list(body_expr)), envir = env)

  arg_names <- names(arg_types)
  wrapper <- function() {
    exec <- environment()
    for (nm in arg_names) {
      check_value(get(nm, envir = exec), arg_types[[nm]])
    }
    result <- do.call(fun, mget(names(formals(fun)), envir = exec))
    if (!is.null(return_type)) {
      check_value(result, return_type)
    }
    result
  }
  formals(wrapper) <- formals(fun)
  wrapper
}
