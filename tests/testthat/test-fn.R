test_that("fn() types arguments given as blaze types", {
  add <- fn(x = int(1), y = int(1), x + y)
  expect_identical(add(2L, 3L), 5L)
  expect_error(add(2L, "x"), "expected integer, got character")
})

test_that("fn() checks the return type", {
  bad <- fn(x = int(1), .returns = chr(), x)
  expect_error(bad(1L), "expected character, got integer")
})

test_that("fn() supports refinements and multi-line bodies", {
  stats <- fn(x = dbl() |> nonneg(), {
    m <- mean(x)
    list(mean = m, n = length(x))
  })
  expect_identical(stats(c(2, 4)), list(mean = 3, n = 2L))
  expect_error(stats(c(1, -1)), "expected non-negative values")
})

test_that("fn() keeps ordinary defaults on untyped arguments", {
  scale <- fn(x = dbl(), by = 2, x * by)
  expect_identical(scale(c(1, 2)), c(2, 4))
  expect_identical(scale(c(1, 2), by = 10), c(10, 20))
})

test_that("fn() makes typed arguments required", {
  add <- fn(x = int(1), y = int(1), x + y)
  expect_error(add(2L), "missing")
})
