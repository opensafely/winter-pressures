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
  6, as.Date("2021-06-01"), 1000, 899,
  6, as.Date("2021-12-01"), 1000, 999,
  7, as.Date("2021-06-01"), 1000, 900,
  7, as.Date("2021-12-01"), 1000, 999,
  8, as.Date("2021-06-01"), 1000, 1100,
  8, as.Date("2021-12-01"), 1000, 999,
  9, as.Date("2021-06-01"), 1000, 999,
  9, as.Date("2021-12-01"), 1000, 1101,
  
)

output_expected_valid <- c(2,3,4,5,6,9)

context("Testing the function get_practices_with_population_change()")

test_that( desc = "practices with >10% population change", {
  
  output_observed_valid = get_practices_with_population_change(
    joined_data = input_d_valid,
    percentage_threshold = 10
  )
  
  expect_equal(output_observed_valid, output_expected_valid)
})
