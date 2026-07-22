test_that("NA is rejected by default", {
  expect_error(check(c(1L, NA), t_int()), "unexpected NA")
  expect_error(check(c(1.5, NA), t_dbl()), "unexpected NA")
  expect_error(check(c("a", NA), t_chr()), "unexpected NA")
  expect_error(check(c(TRUE, NA), t_lgl()), "unexpected NA")
})

test_that("t_na_ok() permits NA", {
  expect_true(t_na_ok(t_int())@na_ok)
  expect_identical(check(c(1L, NA), t_na_ok(t_int())), c(1L, NA))
})

test_that("na_ok is FALSE by default", {
  expect_false(t_int()@na_ok)
})

test_that("a value without NA passes", {
  expect_identical(check(1:3, t_int()), 1:3)
})
