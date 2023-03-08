library(tibble)

input_d_valid = tribble(
  ~practice,  ~season, ~year, ~value,
  1, 0, 2021, 0.1,
  1, 1, 2021, 0.2,
  2, 0, 2021, 0.3,
  2, 1, 2021, 0.4,
  3, 0, 2021, 0.5,
  3, 1, 2022, 0.6,
  4, 0, 2022, 0.7,
  4, 1, 2022, NA,
  5, 0, 2021, 0.1,
  5, 1, 2021, 0.2,
)

input_practices_to_remove <- c(3,5)

output_expected_valid = tribble(
  ~practice,  ~season, ~year, ~value,
  1, 0, 2021, 0.1,
  1, 1, 2021, 0.2,
  2, 0, 2021, 0.3,
  2, 1, 2021, 0.4,
  4, 0, 2022, 0.7,
  4, 1, 2022, NA,
)

context("Testing the function remove_practices_from_season_data()")

test_that( desc = "Remove practices from season data", {

  
  output_observed_valid = remove_practices_from_season_data(
    season_data = input_d_valid,
    practices_to_remove = input_practices_to_remove
  )
  
  expect_equal(output_observed_valid, output_expected_valid)
})