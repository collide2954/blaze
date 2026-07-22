# blaze 0.1.0

First release. blaze adds strict, opt-in, runtime type checking to ordinary R
code. Types are written with a terse vocabulary that lives inside blaze's own
constructs (so it never clashes with other packages) and are enforced by a Rust
engine.

## Type vocabulary

* Base types `int()`, `dbl()`, `chr()`, `lgl()`, `cpl()`, `raw()`, `lst()`, each
  with `len`/`min`/`max` length constraints.
* Modifiers `na_ok()` (permit `NA`, which is rejected by default) and `opt()`
  (permit `NULL`).
* Refinements composed with the pipe: `nonneg()`, `between()`, `matches()`,
  `unique_vals()`, `nchar_between()`.
* Composite types `any()`, `cls()`, `fct()`, `list_of()`, `one_of()`.
* Data-frame schemas via `frame()`, with per-column types and row or
  cross-column invariants via `where()`. Every violation is reported together.

## Surfaces

* `check(value, type)` validates a value, returning it invisibly or raising a
  precise error.
* `fn()` is a drop-in for `function()` that type-checks arguments on entry and
  the result on exit: `add <- fn(x = int(1), y = int(1), x + y)`.
* `type()` builds a standalone, reusable type; `blaze_types()` lists the
  vocabulary.

## Known limitations

* `fn()` does not yet support `...` (dots) or a runtime default value on a typed
  argument.
