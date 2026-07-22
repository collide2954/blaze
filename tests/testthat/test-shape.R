test_that("constructors record length bounds", {
  expect_identical(t_int(1)@len_min, 1L)
  expect_identical(t_int(1)@len_max, 1L)
  expect_identical(t_dbl(len = 3)@len_min, 3L)
  expect_identical(t_int()@len_min, integer(0))
  expect_identical(t_chr(min = 1)@len_min, 1L)
  expect_identical(t_chr(min = 1)@len_max, integer(0))
  expect_identical(t_dbl(min = 0, max = 10)@len_min, 0L)
  expect_identical(t_dbl(min = 0, max = 10)@len_max, 10L)
})

test_that("check() enforces an exact length", {
  expect_invisible(check(1L, t_int(1)))
  expect_identical(check(1L, t_int(1)), 1L)
  expect_error(check(1:3, t_int(1)), "expected length 1, got length 3")
})

test_that("check() enforces min and max length bounds", {
  expect_identical(check("a", t_chr(min = 1)), "a")
  expect_error(check(character(0), t_chr(min = 1)), "expected length >= 1, got length 0")
  expect_error(check(rep(1L, 15), t_int(min = 0, max = 10)), "expected length <= 10, got length 15")
})

test_that("length is unconstrained by default", {
  expect_identical(check(1:5, t_int()), 1:5)
})
