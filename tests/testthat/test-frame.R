test_that("frame() builds a data-frame type", {
  schema <- type(frame(id = int(), age = int()))
  expect_identical(schema@base, "data.frame")
  expect_named(schema@columns, c("id", "age"))
})

test_that("check() accepts a conforming data frame", {
  df <- data.frame(id = 1:3, age = c(20L, 30L, 40L))
  expect_identical(
    check(df, frame(id = int() |> unique_vals(), age = int() |> nonneg())),
    df
  )
})

test_that("check() reports a non-data-frame", {
  expect_error(check(1:3, frame(id = int())), "expected a data frame")
})

test_that("check() reports a missing column", {
  expect_error(check(data.frame(x = 1L), frame(id = int())), "missing column `id`")
})

test_that("check() reports a bad column type", {
  expect_error(
    check(data.frame(id = "a"), frame(id = int())),
    "column `id`: expected integer, got character"
  )
})

test_that("check() applies column refinements", {
  df <- data.frame(id = 1:2, age = c(20L, -5L))
  expect_error(
    check(df, frame(id = int(), age = int() |> nonneg())),
    "column `age`: expected non-negative"
  )
})

test_that("a frame type drops into fn()", {
  mean_age <- fn(data = frame(age = int() |> nonneg()), mean(data$age))
  expect_identical(mean_age(data.frame(age = c(2L, 4L))), 3)
})
