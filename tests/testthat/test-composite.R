test_that("any() accepts anything", {
  expect_identical(check(1L, any()), 1L)
  expect_identical(check("x", any()), "x")
  expect_null(check(NULL, any()))
})

test_that("cls() checks an object's class", {
  d <- as.Date("2020-01-01")
  expect_identical(check(d, cls("Date")), d)
  expect_error(check(1L, cls("Date")), "expected an object of class `Date`")
})

test_that("fct() checks factor levels", {
  f <- factor("ctrl", levels = c("ctrl", "treat"))
  expect_identical(check(f, fct(c("ctrl", "treat"))), f)
  expect_error(check(1L, fct(c("a"))), "expected a factor")
  expect_error(check(factor("x"), fct(c("ctrl", "treat"))), "unexpected factor levels: x")
})

test_that("list_of() checks element types", {
  expect_identical(check(list(1L, 2L), list_of(int())), list(1L, 2L))
  expect_error(check(list(1L, "x"), list_of(int())), "element 2: expected integer, got character")
  expect_error(check(1L, list_of(int())), "expected a list")
})

test_that("one_of() accepts any alternative", {
  expect_identical(check(1L, one_of(int(), chr())), 1L)
  expect_identical(check("x", one_of(int(), chr())), "x")
  expect_error(check(TRUE, one_of(int(), chr())), "expected one of: integer, character")
})
