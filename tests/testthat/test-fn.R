test_that("fn() checks argument types", {
  add <- fn(x ~ t_int(1), y ~ t_int(1), .returns = t_int(1), function(x, y) x + y)
  expect_identical(add(2L, 3L), 5L)
  expect_error(add(2L, "x"), "expected integer, got character")
})

test_that("fn() checks the return type", {
  bad <- fn(x ~ t_int(1), .returns = t_chr(), function(x) x)
  expect_error(bad(1L), "expected character, got integer")
})

test_that("fn() leaves unannotated arguments unchecked", {
  f <- fn(x ~ t_int(1), function(x, y) x)
  expect_identical(f(1L, "anything"), 1L)
})

test_that("fn() supports the named-argument form", {
  add <- fn(x = t_int(1), y = t_int(1), .returns = t_int(1), function(x, y) x + y)
  expect_identical(add(2L, 3L), 5L)
})
