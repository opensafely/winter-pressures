library(tibble)

#######################################################################
# create dummy data for testing
####################################################################### 

# create input data 
input_data <- tibble(date =  rep(c(as.Date("2021-06-01"), 
                   as.Date("2021-12-01")), 
                   each = 3),
       practice = c(1:3, 1:3),
       population = rep(c(10, 100, 1000), times = 2),
       sro_measure = c(7, 4, 235, 2, 57, 982),
       value = sro_measure / population
)

expected_output <-  tibble(year =  rep(2021, 
                                       length.out = 6),
                           practice = c(1:3, 1:3),
                           season = rep(c(0L , 1L), each = 3),
                           value = c(7/10, 4/100, 235/1000, 2/10, 57/100, 982/1000)
)



#######################################################################
# tests
####################################################################### 

context("Testing the function season_assignment()")

test_that( desc = "season_assignment with valid data", {
  
  func_output <- season_assignment(
    measure_data = input_data
  )
  
  expect_setequal(names(expected_output), names(func_output))
  expect_equal(expected_output$year, func_output$year)
  expect_equal(expected_output$practice, func_output$practice)
  expect_equal(expected_output$season, func_output$season)
  expect_equal(expected_output$value, func_output$value)
})


