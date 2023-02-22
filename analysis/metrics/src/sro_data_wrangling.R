#######################################################################
# read in SRO measure data and aggregate to season
#######################################################################  

get_season_aggregate_sro_measure <- function(sro_measure_name,
                                             summer_months,
                                             winter_months){
  
  # read in and format SRO measure data
  measure_data <- get_and_format_sro_measure_data(sro_measure_name = sro_measure_name)
  
  season_data <- join_sro_measure_to_season(measure_data = measure_data,
                                            summer_months = summer_months,
                                            winter_months = winter_months)
  
  # set output directory
  output_directory <- fs::dir_create(here("output", 
                                          "metrics", 
                                          sro_measure_name),
                                     recurse = TRUE)
  # save out data as csv
  write_csv(season_data,
            file = here(output_directory, 
                        "season_data.csv"))
  
}


#######################################################################
# join measure data to season lookup table
####################################################################### 

join_sro_measure_to_season <- function(measure_data,
                                       summer_months,
                                       winter_months){
  
  # create season lookup table for all the dates in the measure data
  season_lookup <- season_assignment(measure_data = measure_data,
                                     summer_months = summer_months,
                                     winter_months = winter_months)
  
  # join season data to measure data
  measure_data <- left_join(measure_data,
                            season_lookup,
                            by = c("date" = "date"))
  
  # remove any rows with NAs
  measure_data <- drop_na(measure_data)
  
  # calculate measure value on aggregated season data, grouped by practice, 
  #  season, and seasonal year
  
  grouping_variables <- c("practice",
                          "season",
                          "year"
  )
  
  season_data <- generate_season_summary_data(
    grouping_variables = grouping_variables,
    measure_data = measure_data)
  
  print(season_data)
  season_data
  
}


#######################################################################
# read in and format SRO measure data
#######################################################################  

get_and_format_sro_measure_data <- function(sro_measure_name){

  # read in sro measure data
  measure_data <- read_csv(file = here("output", 
                                       "metrics", 
                                       paste0("measure_", 
                                              sro_measure_name, 
                                              "_practice_only_rate.csv")),
                           col_types = cols(
                             date = col_date(),
                             practice = col_double(),
                             population = col_double(),
                             value = col_double(),
                             "{sro_measure_name}" := col_double()
                           )
  )
  
  # standardise column names
  measure_data <- pivot_longer(measure_data,
                               cols = all_of(sro_measure_name),
                               names_to = "sro_measure_name", 
                               values_to = "measure_count")
  
  # remove "value" column
  # we need to calculate our proportions using a different denominator to the 
  # measures framework, therefore the imported "value" column is incorrect
  measure_data <- select(measure_data,
                         !(value))
  
  measure_data
}

#######################################################################
# create a lookup table for season indexing
#######################################################################

# each date in our data must be assigned a season: summer or winter
# each summer season must have a corresponding winter season for comparison, and
#  we always consider summer to occur before winter
# paired seasons will be identified by an index: "year" column, representing the 
#  year that the season begins
# a summer season and a winter season must contain the same number of months; we 
#  create an index to identify the 1st, 2nd etc month within a season


# Generate monthly lookup table n years
season_assignment <- function(measure_data,
                              summer_months,
                              winter_months){
  
  # find the start date(s) for our season year within the data
  seasonal_year_start_date <- unique(
    measure_data$date[month(measure_data$date) == min(summer_months) &
                        day(measure_data$date) == 1]
  )
  
  # find all the dates that appear in our measure data
  measure_data_dates <- unique(measure_data$date)
  
  # find number of seasonal years (start date only) in our data
  n <- length(seasonal_year_start_date)
  
  # generate lookup table list with addition of a season_year_index
  season_lookup <- lapply(
    1:n,
    function(n){
      tib <- single_year_season_assignment(
        seasonal_year_start_date = seasonal_year_start_date[n],
        summer_months = summer_months,
        winter_months = winter_months)
      
      tib <- mutate(tib,
                    year = year(seasonal_year_start_date[n]))
      
      # check that all dates in our lookup table appear in the measure data
      check_dates <- all(unique(tib$date) %in% measure_data_dates)
      
      if(check_dates == TRUE){
        
        # if all dates in lookup table are in measure data then no change
        tib <- tib
      } else {
        
        # if some dates appear in lookup table but not in measure data then 
        #  change the season to NA for all rows. Rows with NA season will be 
        #  removed later.
        tib <- mutate(tib, 
                      season = NA_integer_)
      }
      
      tib
      
    }
  )
  
  # flatten the list and return lookup table
  season_lookup <- bind_rows(season_lookup)
  
  season_lookup
}


# Generate monthly lookup table 1 year period beginning on start date
single_year_season_assignment <- function(seasonal_year_start_date,
                                          summer_months,
                                          winter_months){ 
  
  # check lengths of summer_months and winter_months are equal
  if(length(summer_months) != length(winter_months)){ 
    stop("Error: Different number of months defined in summer compared to winter")
  }
  
  # calculate the season year end date (using 1st of the month)
  seasonal_year_end_date <- seasonal_year_start_date %m+% months(11)
  
  # generate monthly tibble for the year and assign seasons
  tib <- tibble(date = as.Date(seq(seasonal_year_start_date,
                                   seasonal_year_end_date,
                                   by = "months")),
                season = case_when(month(date) %in% summer_months ~ 0L,
                                   month(date) %in% winter_months ~ 1L,
                                   !(month(date) %in% c(summer_months, winter_months)) ~ NA_integer_,
                ))
  
  
  # remove the months with no assigned season (NAs)
  tib <- drop_na(tib, season)
  
  tib <- mutate(tib,
                season_month_index = rep(1:length(summer_months), 
                                         length.out = 2*length(summer_months)))
  
  tib
}

#######################################################################
# aggregate data to season and calculate proportion
#######################################################################

# take the measure data and aggregate to season values by the grouping variables
generate_season_summary_data <- function(grouping_variables,
                                         measure_data){

  # create data that is grouped
  season_data <- group_by(measure_data,
                          across(all_of(grouping_variables)))
  
  # summarise the data:
  # numerator: sum the measure count values over the 4 months
  # denominator: take the median population size over the 4 months
  season_data <- summarise(season_data,
                           numerator = sum(measure_count),
                           denominator = median(population),
                           .groups = "keep")
  
  # calculate proportion by season
  season_data <- mutate(season_data,
                        value = numerator/denominator)
  
  select(season_data,
         !(c(numerator, denominator)))
  
}



