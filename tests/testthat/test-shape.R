test_that("constructors record an exact length", {
  expect_identical(t_int(1)@len, 1L)
  expect_identical(t_dbl(len = 3)@len, 3L)
  expect_identical(t_int()@len, integer(0))
})

test_that("check() enforces an exact length", {
  expect_invisible(check(1L, t_int(1)))
  expect_identical(check(1L, t_int(1)), 1L)
  expect_error(check(1:3, t_int(1)), "expected length 1, got length 3")
})

test_that("length is only enforced when specified", {
  expect_identical(check(1:5, t_int()), 1:5)
})
