#######################################################################
# widen season data
#######################################################################


# Widen the data so that seasons are column headings, and proportions are the 
#  column values.
# Remove all rows that have NA values; this ensures a practice has both a summer 
#  and winter value. 
generate_wide_season_data <- function(season_data){
  
  # create wider data with summer and winter as columns
  wide_season_data <- pivot_wider(season_data,
                                  names_from = season,
                                  values_from = value)
  wide_season_data <- rename(wide_season_data,
                             summer = `0`,
                             winter = `1`)
  
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
