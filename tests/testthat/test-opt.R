test_that("NULL is rejected by default", {
  expect_error(check(NULL, t_int()), "expected integer, got NULL")
})

test_that("t_opt() permits NULL", {
  expect_true(t_opt(t_int())@optional)
  expect_null(check(NULL, t_opt(t_int())))
})

test_that("optional is FALSE by default", {
  expect_false(t_int()@optional)
})

test_that("t_opt() still checks non-NULL values", {
  expect_identical(check(5L, t_opt(t_int())), 5L)
  expect_error(check("a", t_opt(t_int())), "expected integer, got character")
})
