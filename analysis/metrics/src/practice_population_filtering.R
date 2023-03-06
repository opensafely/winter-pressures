#######################################################################
# Get the practices to remove
#######################################################################

get_practices_to_remove <- function(measure_name,
                                    percentage_threshold,
                                    population_size_threshold){
  
  start_population_data <- get_start_population_data(measure_name)
  
  end_population_data <- get_end_population_data(measure_name)
  
  # do a full join of both data sets
  population_data <- full_join(start_population_data,
                               end_population_data,
                               by = c("practice", 
                                      "date")
  )
  
  # get the unique practices with population change or NA values
  practices_with_population_change <- 
    get_practices_with_population_change(joined_data = population_data,
                                         percentage_threshold = percentage_threshold)
  
  # get the unique practices with a small population or NA values
  practices_with_small_population <-
    get_practices_with_small_start_population(joined_data = population_data,
                                              population_size_threshold = population_size_threshold)
  
  #return the unique practices that are either: 
  #small population, large population change, NA population
  unique(c(practices_with_population_change,
         practices_with_small_population)
  )
  
}

#######################################################################
# identify practices with small population
#######################################################################

get_practices_with_small_start_population <- function(joined_data,
                                                      population_size_threshold){

  dat <- filter(joined_data,
                is.na(start_population) | start_population < population_size_threshold)
  
  practices <- unique(pull(dat,
                           practice))
  
  practices
  
}

#######################################################################
# identify large change in practice population
#######################################################################

get_practices_with_population_change <- function(joined_data,
                                                 percentage_threshold){
  
  # calculate a population percentage change (absolute value) from start 
  #  population to end population
  dat <- 
    mutate(joined_data,
           population_pc_change = 
             abs(100*(start_population - end_population) / start_population)
    )
  # filter data to practices with a percent change of NA or less than the threshold value
  dat_to_remove <- 
    filter(dat,
           is.na(population_pc_change) | population_pc_change > percentage_threshold)
  
  # get the unique practice IDs from dat_to_remove
  practices <- unique(pull(dat_to_remove,
                           practice))
  
  practices
  
}

#######################################################################
# read in the start population data
#######################################################################  

get_start_population_data <- function(measure_name){
  
  # read in and format the start population data, necessary columns only
  # for SRO, 'alt' metric chosen because it is first alphabetically 
  
  if(measure_name %in% c("sro", 
                         "over12_appt_pop_rate", 
                         "under12_appt_pop_rate"
  )
  ){
    
    if(measure_name == "sro"){
      start_measure_name <- "alt_practice_only_rate"
    } else {
      start_measure_name <- measure_name
    }
    
    start_population_data <- read_csv(
      file = here("output", 
                  "metrics", 
                  paste0("measure_",
                         start_measure_name,
                         ".csv")
      ),
      col_types = cols_only(
        practice=col_double(),
        date=col_date(format="%Y-%m-%d"),
        population=col_double()
      )
    )
    
    start_population_data <- rename(
      start_population_data,
      start_population = population
    )
    
  } else if(measure_name == "over12_appt_rate") {
    
    start_population_data <- read_csv(
      file = here("output", 
                  "metrics", 
                  paste0("measure_",
                         measure_name,
                         ".csv")
      ),
      col_types = cols_only(
        practice = col_double(),
        date = col_date(format="%Y-%m-%d"),
        population_over12 = col_double()
      )
    )
    
    start_population_data <- rename(
      start_population_data,
      start_population = population_over12
    )
    
  } else if (measure_name == "under12_appt_rate") {
    
    start_population_data <- read_csv(
      file = here("output", 
                  "metrics", 
                  paste0("measure_",
                         measure_name,
                         ".csv")
      ),
      col_types = cols_only(
        practice = col_double(),
        date = col_date(format="%Y-%m-%d"),
        population_under12 = col_double()
      )
    )
    
    start_population_data <- rename(
      start_population_data,
      start_population = population_under12
    )
    
  } else {
    stop(message("Invalid measure_name entered"))
  }
  
  start_population_data
  
}

#######################################################################
# read in the end population data
#######################################################################  

get_end_population_data <- function(measure_name){
  
  # read in the end population data, necessary columns only
  
  if(measure_name %in% c("sro", 
                         "over12_appt_pop_rate", 
                         "under12_appt_pop_rate"
  )
  ){
    
    if(measure_name == "sro"){
      
      end_measure_name <- measure_name
      
    } else if(measure_name == "over12_appt_pop_rate") {
      
      end_measure_name <- "over12"
      
    } else if(measure_name == "under12_appt_pop_rate") {
      
      end_measure_name <- "under12" 
    }
    
    end_population_data <- read_csv(
      file = here("output", 
                  "metrics", 
                  paste0("measure_end_population_",
                         end_measure_name,
                         ".csv")
      ),
      col_types = cols_only(
        practice=col_double(),
        date=col_date(format="%Y-%m-%d"),
        population=col_double()
      )
    )
    
    end_population_data <- rename(
      end_population_data,
      end_population = population
    )
    
  } else if(measure_name == "over12_appt_rate") {
    
    end_population_data <- read_csv(
      file = here("output", 
                  "metrics", 
                  "measure_end_population_over12.csv"
      ),
      col_types = cols_only(
        practice = col_double(),
        date = col_date(format = "%Y-%m-%d"),
        population_over12 = col_double()
      )
    )
    
    end_population_data <- rename(
      end_population_data,
      end_population = population_over12
    )
    
    
  } else if (measure_name == "under12_appt_rate") {
    
    end_population_data <- read_csv(
      file = here("output", 
                  "metrics", 
                  "measure_end_population_under12.csv"
      ),
      col_types = cols_only(
        practice = col_double(),
        date = col_date(format = "%Y-%m-%d"),
        population_under12 = col_double()
      )
    )
    
    end_population_data <- rename(
      end_population_data,
      end_population = population_under12
    )
    
  } else {
    stop(message("Invalid measure_name entered"))
  }
  
  end_population_data
  
}