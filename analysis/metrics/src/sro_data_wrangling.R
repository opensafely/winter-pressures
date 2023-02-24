#######################################################################
# read in SRO measure data and aggregate to season
#######################################################################  

get_season_aggregate_sro_measure <- function(sro_measure_name){

  measure_data <- read_csv(file = here("output", 
                                       "metrics", 
                                       paste0("measure_", 
                                              sro_measure_name, 
                                              "_practice_only_rate.csv")),
                          col_types = cols_only(
                            population = col_double(),
                            practice=col_double(),
                            date=col_date(format="%Y-%m-%d"),
                            value=col_double()
                          )
                        )

  measure_data <- season_assignment(measure_data = measure_data)
  
  print(measure_data)
  
  # save out data as csv
  write_csv(measure_data,
            path = here("output",
                        "metrics",
                        paste0("season_data_", sro_measure_name, ".csv")
            )
  )
  
}

#######################################################################
# assign season to data
#######################################################################

season_assignment <- function(measure_data){
  
  measure_data <- mutate(measure_data,
                         year = year(date))
  
  
  # summer = 0, winter = 1
  measure_data <- mutate(
    measure_data,
    season = case_when(month(date) == 6 ~ 0L,
                       month(date) == 12 ~ 1L,
                       !(month(date) %in% c(6, 12)) ~ NA_integer_)
  )
  
  measure_data <- select(measure_data,
                         c(practice, value, year, season))
  
  measure_data
  
}