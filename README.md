# blaze

Strict, opt-in, runtime type checking for R. Add a type to a function argument,
a value, or a data-frame column — one at a time, wherever you want — and blaze
enforces it at runtime, backed by a Rust engine for speed.

blaze is not a separate language and not a compiler. It is ordinary R you call,
so you can retrofit types onto code you already have without rewriting it.

## Installation

blaze is built with Rust, so installing from source needs a Rust toolchain
(`rustc >= 1.85`) in addition to the usual R build tools:

```r
# from a local clone of the repository
# install.packages("devtools")
devtools::install()
```

## Quick start

```r
library(blaze)

# Values ---------------------------------------------------------------
check(5L, int(1))                          # ok, returns 5L invisibly
check("x", int(1))                         # Error: expected integer, got character
check(c(0.2, 0.9), dbl() |> between(0, 1)) # ok

# Functions — fn() is a drop-in for function() -------------------------
add <- fn(x = int(1), y = int(1), x + y)
add(2L, 3L)                                # 5
add(2L, "x")                               # Error: expected integer, got character

# Data frames ----------------------------------------------------------
Patient <- frame(
  id  = int() |> unique_vals(),
  age = int() |> between(0, 120),
  grp = fct(c("ctrl", "treat"))
) |> where(age >= 18)

check(patients, Patient)
#> Error: data frame does not conform:
#> - column `age`: expected values in [0, 120]
#> - row invariant failed: age >= 18
```

Every failure in a data frame is reported together, so you fix a schema in one
pass rather than one error at a time.

## The type vocabulary

blaze's type names are deliberately terse, and they live *only* inside blaze's
own constructs (`fn()`, `check()`, `type()`, `frame()`). They are never exported
as top-level functions, so they never clash with base R, rlang, dplyr, forcats,
and friends. Run `blaze_types()` to list them, and `?int` (or any other name) to
read about them.

- **Base** — `int` `dbl` `chr` `lgl` `cpl` `raw` `lst`, each taking `len`
  (exact) or `min`/`max` length bounds.
- **Modifiers** — `na_ok()` (blaze rejects `NA` by default), `opt()` (allow
  `NULL`).
- **Refinements**, composed with the pipe — `nonneg()`, `between(lo, hi)`,
  `matches(pattern)`, `unique_vals()`, `nchar_between(lo, hi)`.
- **Composites** — `any()`, `cls("Date")`, `fct(levels)`, `list_of(int())`,
  `one_of(int(), chr())`.
- **Data frames** — `frame(col = type, ...)` and `where(...)` for row or
  cross-column invariants.

To build a reusable type outside those constructs, wrap it in `type()`:

```r
Probability <- type(dbl(1) |> between(0, 1))
check(0.5, Probability)
```

## Design

One type algebra, three surfaces (values, function signatures, data frames).
Checking is strict by default (a passing check is a real guarantee — no silent
coercion, and `NA` must be opted into). Unannotated code is left alone, so types
are something you add where you want a guarantee, not a tax on every line.

## Limitations

- `fn()` does not yet support `...` (dots) or a runtime default value on a typed
  argument.

## License

Apache License 2.0.
