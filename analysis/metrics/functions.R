#######################################################################
# create a lookup table for season indexing
#######################################################################

# Generate monthly lookup table n years
season_assignment <- function(measure_data,
                              summer_months,
                              winter_months){
  
  # Generate monthly lookup table 1 year period beginning on start date
  single_year_season_assignment <- function(seasonal_year_start_date,
                                            summer_months,
                                            winter_months){ 
    
    # calculate the year end date (1st of the month)
    seasonal_year_end_date <- seasonal_year_start_date %m+% months(11)
    
    # generate monthly tibble for the year and assign seasons
    tib <- tibble(date = as.Date(seq(seasonal_year_start_date,
                                     seasonal_year_end_date,
                                     by = "months")),
                  season = case_when(month(date) %in% summer_months ~ "summer",
                                     month(date) %in% winter_months ~ "winter",
                                     !(month(date) %in% c(summer_months, winter_months)) ~ NA_character_,
                  ))
    
    
    # remove the months with no assigned season (NAs)
    tib <- drop_na(tib, season)
    
    # Check that the data have the correct number of months (equal number in summer
    #  and winter), ie no season is missing a month 
    #  a month
    check_months <- identical(sort(month(tib$date)), 
                              sort(c(summer_months, winter_months)))
    
    # if check_months == TRUE, assign season_month_index: an index  to enable 
    #  matching month o1 with summer to month 1 of winter etc otherwise return NA
    if(check_months == TRUE){
      
      tib <- mutate(tib,
                    season_month_index = rep(1:length(summer_months), 
                                             length.out = 2*length(summer_months)))
      
    } else {
      tib <- NA
    }
    
    # return the data, or NA if check_months condition is FALSE
    tib
  }
  
  # find the start date(s) for our season year within the data
  seasonal_year_start_date <- unique(
    measure_data$date[month(measure_data$date) == min(summer_months) &
                        day(measure_data$date) == 1]
  )
  
  # number of year start dates
  n <- length(seasonal_year_start_date)
  
  # generate lookup table list with addition of a season_year_index
  season_lookup <- lapply(1:n,
         function(n){
           tib <- single_year_season_assignment(
             seasonal_year_start_date = seasonal_year_start_date[n],
             summer_months = summer_months,
             winter_months = winter_months)
           
           tib <- mutate(tib,
                         season_year_index = n)
           
           tib
           
         }
  )
  
  # flatten the list and return lookup table
  season_lookup <- bind_rows(season_lookup)
  
  season_lookup
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
                           denominator = median(population))
  
  # calculate proportion by season
  season_data <- mutate(season_data,
                        proportion = numerator/denominator)
  
  season_data
  
}

#######################################################################
# widen season data
#######################################################################


# Widen the data so that seasons are column headings, and proportions are the 
#  column values.
# Remove all rows that have NA values; this ensures a practice has both a summer 
#  and winter value. 
generate_wide_season_data <- function(season_data){
  
  # drop unnecessary columns
  season_data <- select(season_data,
                        !(c(numerator, denominator)))
  
  # create wider data with summer and winter as columns
  wide_season_data <- pivot_wider(season_data,
                                  names_from = season,
                                  values_from = proportion)
  
  
  wide_season_data <- drop_na(wide_season_data)
  
  wide_season_data
}


#######################################################################
# calculate per practice measures
#######################################################################

calculate_season_difference <- function(wide_season_data){
  mutate(wide_season_data,
         seasonal_difference = winter - summer)
}

calculate_season_ratio <- function(wide_season_data){
  mutate(wide_season_data,
         seasonal_log2_ratio = log2(winter/summer))
}