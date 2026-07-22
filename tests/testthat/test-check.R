test_that("blaze_check_base passes when the base type matches", {
  expect_null(blaze_check_base(1L, "integer"))
  expect_null(blaze_check_base(1.5, "double"))
  expect_null(blaze_check_base("a", "character"))
  expect_null(blaze_check_base(TRUE, "logical"))
  expect_null(blaze_check_base(list(), "list"))
})

test_that("blaze_check_base reports a mismatch with expected and found", {
  expect_identical(blaze_check_base("a", "integer"), "expected integer, got character")
  expect_identical(blaze_check_base(1L, "double"), "expected double, got integer")
})
