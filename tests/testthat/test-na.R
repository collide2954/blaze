test_that("NA is rejected by default", {
  expect_error(check(c(1L, NA), int()), "unexpected NA")
  expect_error(check(c(1.5, NA), dbl()), "unexpected NA")
  expect_error(check(c("a", NA), chr()), "unexpected NA")
  expect_error(check(c(TRUE, NA), lgl()), "unexpected NA")
})

test_that("na_ok() permits NA", {
  expect_true(type(na_ok(int()))@na_ok)
  expect_identical(check(c(1L, NA), na_ok(int())), c(1L, NA))
})

test_that("na_ok is FALSE by default", {
  expect_false(type(int())@na_ok)
})

test_that("a value without NA passes", {
  expect_identical(check(1:3, int()), 1:3)
})
