test_that("nonneg() records a refinement", {
  ty <- t_int() |> nonneg()
  expect_length(ty@refinements, 1)
  expect_identical(ty@refinements[[1]]$kind, "nonneg")
})

test_that("nonneg() rejects negative values", {
  expect_error(check(c(1L, -2L), t_int() |> nonneg()), "non-negative")
  expect_error(check(c(0.5, -0.1), t_dbl() |> nonneg()), "non-negative")
})

test_that("nonneg() accepts non-negative values", {
  expect_identical(check(c(0L, 3L), t_int() |> nonneg()), c(0L, 3L))
})

test_that("nonneg() ignores NA", {
  expect_identical(check(c(1L, NA), t_na_ok(t_int()) |> nonneg()), c(1L, NA))
})

test_that("in_range() enforces numeric bounds", {
  expect_identical(check(c(0, 0.5, 1), t_dbl() |> in_range(0, 1)), c(0, 0.5, 1))
  expect_error(check(c(0.5, 1.5), t_dbl() |> in_range(0, 1)), "expected values in \\[0, 1\\]")
  expect_error(check(c(-1L, 2L), t_int() |> in_range(0, 10)), "expected values in \\[0, 10\\]")
})

test_that("unique_vals() rejects duplicates", {
  expect_identical(check(c(1L, 2L, 3L), t_int() |> unique_vals()), c(1L, 2L, 3L))
  expect_error(check(c(1L, 2L, 2L), t_int() |> unique_vals()), "expected unique values")
})
