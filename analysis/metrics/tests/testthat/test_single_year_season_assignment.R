library(tibble)

# list some test inputs
summer_start <- as.Date("2021-06-01")
summer4 <- c(6,7,8,9)
winter4 <- c(1,2,3,12)
summer3 <- c(6,7,8)
winter3 <- c(1,2,12)


context("Testing the function single_year_season_assignment()")

test_that(desc = "season lookup table with valid season inputs", {
  
  # test that the function returns a tibble of the form output_expected_valid
  
  output_observed_valid <- single_year_season_assignment(
    seasonal_year_start_date = summer_start,
    summer_months = summer4,
    winter_months = winter4
  )
  
  output_expected_valid <- tribble(
    ~date, ~season, ~season_month_index,
    as.Date("2021-06-01"), 0, 1,
    as.Date("2021-07-01"), 0, 2,
    as.Date("2021-08-01"), 0, 3,
    as.Date("2021-09-01"), 0, 4,
    as.Date("2021-12-01"), 1, 1,
    as.Date("2022-01-01"), 1, 2,
    as.Date("2022-02-01"), 1, 3,
    as.Date("2022-03-01"), 1, 4,
  )
  
  expect_equal(output_observed_valid, output_expected_valid)
  
})


test_that(desc = "season lookup table with invalid season inputs", {
  # test that the function returns an error if the number of summer months is 
  # different to the number of winter months
  
  expect_error(
    single_year_season_assignment(
      seasonal_year_start_date = summer_start,
      summer_months = summer4,
      winter_months = winter3
    )
  )
  
})


