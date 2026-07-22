test_that("check() returns the value invisibly on a match", {
  expect_invisible(check(1L, t_int()))
  expect_identical(check(1L, t_int()), 1L)
  expect_identical(check("a", t_chr()), "a")
})

test_that("check() errors on a mismatch, naming expected and found", {
  expect_error(check("a", t_int()), "expected integer, got character")
  expect_error(check(1L, t_dbl()), "expected double, got integer")
})
