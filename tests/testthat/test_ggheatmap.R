context("ggheatmap")

test_that("ggheatmap", {
  x = matrix(runif(25L), ncol = 5L)

  pl = ggheatmap(x)
  expect_class(pl, "ggplot")
})
