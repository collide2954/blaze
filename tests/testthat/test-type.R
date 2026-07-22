test_that("base constructors carry the correct base type", {
  expect_identical(t_int()@base, "integer")
  expect_identical(t_dbl()@base, "double")
  expect_identical(t_chr()@base, "character")
  expect_identical(t_lgl()@base, "logical")
  expect_identical(t_cpl()@base, "complex")
  expect_identical(t_raw()@base, "raw")
  expect_identical(t_list()@base, "list")
})

test_that("base constructors return blaze_type objects", {
  expect_true(S7::S7_inherits(t_int(), blaze_type))
  expect_true(S7::S7_inherits(t_list(), blaze_type))
})
