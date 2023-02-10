#######################################################################
# load libraries
#######################################################################

library(tidyverse)
library(here)
library(dplyr)
library(ggplot2)
library(lubridate)

#######################################################################
# read in files
#######################################################################

measure_name <- "asthma"
filepath <- here("output", "metrics", paste0("measure_", measure_name, "_practice_only_rate.csv"))
measure_data <- read_csv(file = filepath)

#######################################################################
# set directory for outputs
#######################################################################

# this is likely to change to a subdirectory once we have a clearer idea of how 
#  many outputs and how many measures we are doing

output_directory <- here("output", "metrics")

#######################################################################
# reformat the data to desired form
#######################################################################

# standardise column names
measure_data <- pivot_longer(measure_data,
                             cols = all_of(measure_name),
                             names_to = "measure_name", 
                             values_to = "measure_count")

# convert date column from character type to date type
measure_data$date <- as.Date(measure_data$date,
                             tryFormats = c("%d/%m/%Y", "%Y-%m-%d"))

# remove "value" column
# we need to calculate our proportions using a different denominator to the 
# measures framework, therefore the imported "value" column is incorrect
measure_data <- select(measure_data,
                       !(value))

# To Do
# need to add in an option to throw away missing data here, prior to 
# aggregation to seasons and proportion calculation

#######################################################################
# create a lookup table for season indexing
#######################################################################

# define the months associated with each season
# summer: June - September inclusive
# winter: December - March inclusive
summer_months <- c(6:9)
winter_months <- c(1:3, 12)

# each date in our data must be assigned a season: summer or winter
# each summer season must have a corresponding winter season for comparison, and
#  we always consider summer to occur before winter: paired seasons will be 
#  identified by a year index
# a summer season and a winter season must contain the same number of months; we 
#  create an index to identify the 1st, 2nd etc month within a season


season_lookup <- tibble(
  date = unique(measure_data$date),
  day = day(date),
  month = month(date),
  year = year(date),
  season = case_when(month(date) %in% summer_months ~ "summer",
                     month(date) %in% winter_months ~ "winter",
                     !(month(date) %in% c(summer_months, winter_months)) ~ NA_character_,
  ),
  season_month_index = rep(1:length(summer_months), length.out = length(date)),
  season_year_index = rep(c(1:5), each = 2*length(summer_months))[1:length(date)]
)


#######################################################################
# join season information to the measure data
#######################################################################

measure_data <- left_join(measure_data,
                          season_lookup,
                          by = c("date" = "date"))

# check that no months have season NA
print(sum(is.na(measure_data$season)))

#######################################################################
# aggregate data to season and calculate proportion
#######################################################################

# set grouping variables
season_data <- group_by(measure_data,
                        practice,
                        season,
                        season_year_index)

# summarise the data:
# numerator: sum the measure count values over the 4 months
# denominator: take the median population size over the 4 months
season_data <- summarise(season_data,
                         numerator = sum(measure_count),
                         denominator = median(population))


# calculate proportion by season
season_data <- mutate(season_data,
                      proportion = numerator/denominator)

#######################################################################
# reformat the data to calculate per practice measures
#######################################################################

# drop unnecessary columns
season_data <- select(season_data,
                      !(c(numerator, denominator)))

# create wider data with sumemr and winter as columns
wide_season_data <- pivot_wider(season_data,
                                names_from = season,
                                values_from = proportion)

# remove all rows that have NA values - ideally we should be addressing this 
#  earlier by not carrying through any data that is not complete
wide_season_data <- drop_na(wide_season_data)


# calculate seasonal difference and seasonal rate
practice_measure_data <- mutate(wide_season_data,
                                seasonal_difference = summer - winter,
                                seasonal_ratio = winter/summer)

#######################################################################
# create seasonal difference and seasonal ratio histogram
#######################################################################

# create the seasonal difference histogram plot
difference_plot <- ggplot(practice_measure_data) + 
  geom_histogram(aes(x=seasonal_difference), binwidth = 0.05) +
  theme_bw()

# get the data used to create the histogram and select columns of interest
difference_plot_data <- ggplot_build(difference_plot)$data[[1]]
difference_plot_data <- select(difference_plot_data, y, count, x, xmin, xmax, density)


# create the seasonal ratio histogram plot
ratio_plot <- ggplot(practice_measure_data) + 
  geom_histogram(aes(x=seasonal_ratio), binwidth = 0.05) +
  theme_bw()

# get the data used to create the histogram and select columns of interest
ratio_plot_data <- ggplot_build(ratio_plot)$data[[1]]
ratio_plot_data <- select(ratio_plot_data, y, count, x, xmin, xmax, density)

#######################################################################
# save outputs
#######################################################################

ggsave(difference_plot,
       filename = "summer_winter_difference_histogram.png",
       path = output_directory)

write.csv(difference_plot_data,
          file = paste(output_directory,
                       "summer_winter_difference_histogram_data.csv",
                       sep = "/"))


ggsave(ratio_plot,
       filename = "summer_winter_ratio_histogram.png",
       path = output_directory)

write.csv(ratio_plot_data,
          file = paste(output_directory,
                       "summer_winter_ratio_histogram_data.csv",
                       sep = "/"))