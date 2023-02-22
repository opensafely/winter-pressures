library(tibble)

summer_months <- c(6:9)
winter_months <- c(1:3, 12)

input_dat1 <- tibble(date =  seq(as.Date("2021-01-01"), 
                   as.Date("2022-04-01"), 
                   by = "months"),
       practice = rep(1, length.out = length(date)),
       population = rep(100, length.out = length(date)),
       measure_count = 1:length(date),
       measure_name = "test_measure"
)

expected_output1 <- tibble(date =  c(seq(as.Date("2021-06-01"), 
                                         as.Date("2021-09-01"), 
                                         by = "months"),
                                     seq(as.Date("2021-12-01"), 
                                         as.Date("2022-03-01"), 
                                         by = "months")
),
season = rep(c(0,1), each = 4),
season_month_index = rep(1:4, length.out = length(date)),
year = rep(2021, length.out = length(date)),
)



input_dat2 <- tibble(date =  seq(as.Date("2021-01-01"), 
                                 as.Date("2022-06-01"), 
                                 by = "months"),
                     practice = rep(1, length.out = length(date)),
                     population = rep(100, length.out = length(date)),
                     measure_count = 1:length(date),
                     measure_name = "test_measure"
)

expected_output2 <- tibble(
  date =  c(seq(as.Date("2021-06-01"), 
                as.Date("2021-09-01"), 
                by = "months"),
            seq(as.Date("2021-12-01"), 
                as.Date("2022-03-01"), 
                by = "months"),
            seq(as.Date("2022-06-01"), 
                as.Date("2022-09-01"), 
                by = "months"),
            seq(as.Date("2022-12-01"), 
                as.Date("2023-03-01"), 
                by = "months")
  ),
  season = rep(c(0,0,0,0,1,1,1,1), times = 2),
  season_month_index = rep(1:4, length.out = length(date)),
  year = rep(c(2021, 2022), each = 8),
)



season_assignment(
  measure_data = input_dat1,
  summer_months = summer_months,
  winter_months = winter_months
)



context("Testing the function season_assignment()")

test_that( desc = "season_assignment with valid data", {
  
  expect_equal(season_assignment(
    measure_data = input_dat1,
    summer_months = summer_months,
    winter_months = winter_months
  ), 
  expected_output1)
})

test_that( desc = "season_assignment with valid data", {
  
  expect_equal(season_assignment(
    measure_data = input_dat2,
    summer_months = summer_months,
    winter_months = winter_months
  ), 
  expected_output2)
})






