test_that("base constructors carry the correct base type", {
  expect_identical(type(int())@base, "integer")
  expect_identical(type(dbl())@base, "double")
  expect_identical(type(chr())@base, "character")
  expect_identical(type(lgl())@base, "logical")
  expect_identical(type(cpl())@base, "complex")
  expect_identical(type(raw())@base, "raw")
  expect_identical(type(lst())@base, "list")
})

test_that("base constructors return blaze_type objects", {
  expect_true(S7::S7_inherits(type(int()), blaze_type))
  expect_true(S7::S7_inherits(type(lst()), blaze_type))
})
