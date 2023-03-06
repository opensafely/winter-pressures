library(tibble)

input_d_valid <- tribble(
  ~practice, ~date,  ~start_population, ~end_population,
  1, as.Date("2021-06-01"), 1000, 999,
  1, as.Date("2021-12-01"), 1000, 999,
  2, as.Date("2021-06-01"), 100, 999,
  2, as.Date("2021-12-01"), 1000, 999,
  3, as.Date("2021-06-01"), NA, 999,
  3, as.Date("2021-12-01"), 1000, 999,
  4, as.Date("2021-06-01"), 1000, 999,
  4, as.Date("2021-12-01"), 1000, NA,
  5, as.Date("2021-06-01"), 1000, 3,
  5, as.Date("2021-12-01"), 1000, 999,
  6, as.Date("2021-06-01"), 500, 999,
  6, as.Date("2021-12-01"), 1000, 999,
  7, as.Date("2021-06-01"), 499, 999,
  7, as.Date("2021-12-01"), 1000, 999,

)

output_expected_valid <- c(2,3,7)

context("Testing the function get_practices_with_small_start_population()")

test_that( desc = "Practices with start population size <500", {
  
  output_observed_valid = get_practices_with_small_start_population(
    joined_data = input_d_valid,
    population_size_threshold = 500
  )
  
  expect_equal(output_observed_valid, output_expected_valid)
})

