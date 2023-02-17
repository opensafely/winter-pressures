rm(list = ls())

#######################################################################
# load libraries
#######################################################################

library(tidyverse)
library(here)
library(dplyr)
library(ggplot2)
library(lubridate)

#######################################################################
# source files
#######################################################################

source(here("analysis", "metrics", "functions.R"))

#######################################################################
# read in files
#######################################################################

measure_name <- "asthma"

measure_data <- read_csv(file = here("output", 
                                     "metrics", 
                                     paste0("measure_", 
                                            measure_name, 
                                            "_practice_only_rate.csv")))

#######################################################################
# set directory for outputs
#######################################################################

# this is likely to change to a subdirectory once we have a clearer idea of how 
#  many outputs and how many measures we are doing

output_directory <- fs::dir_create(here("output", 
                                        "metrics", 
                                        measure_name),
                                   recurse = TRUE)

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

#######################################################################
# create a lookup table for season indexing
#######################################################################

# define the months associated with each season
# summer: June - September inclusive
# winter: December - March inclusive
summer_months <- c(6:9)
winter_months <- c(1:3, 12)
# need to check the season lengths are the same

# each date in our data must be assigned a season: summer or winter
# each summer season must have a corresponding winter season for comparison, and
#  we always consider summer to occur before winter: paired seasons will be 
#  identified by a year index
# a summer season and a winter season must contain the same number of months; we 
#  create an index to identify the 1st, 2nd etc month within a season

season_lookup <- season_assignment(measure_data = measure_data,
                                   summer_months = summer_months,
                                   winter_months = winter_months)

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

# define grouping variables
grouping_variables <- c("practice",
                        "season",
                        "season_year_index"
)

season_data <- generate_season_summary_data(
  grouping_variables = grouping_variables,
  measure_data = measure_data)

#######################################################################
# reformat the data to calculate per practice measures
#######################################################################

wide_season_data <- generate_wide_season_data(season_data = season_data)

# calculate seasonal difference and seasonal rate ratio
practice_measure_data <- calculate_season_difference(
  wide_season_data = wide_season_data)

practice_measure_data <- calculate_season_ratio(
  wide_season_data = practice_measure_data)


practice_measure_data <- mutate(wide_season_data,
                                seasonal_difference = winter - summer,
                                seasonal_log2_ratio = log2(winter/summer))



#######################################################################
# create seasonal difference and seasonal ratio histogram
#######################################################################

# create the seasonal difference histogram plot
difference_plot <- ggplot(practice_measure_data) + 
  geom_histogram(aes(x=seasonal_difference), 
                 binwidth = 0.05) +
  theme_bw()

# get the data used to create the histogram and select columns of interest
difference_plot_data <- ggplot_build(difference_plot)$data[[1]]
difference_plot_data <- select(difference_plot_data, 
                               y, 
                               count, 
                               x, 
                               xmin, 
                               xmax, 
                               density)


# create the seasonal ratio histogram plot
ratio_plot <- ggplot(practice_measure_data) + 
  geom_histogram(aes(x=seasonal_log_ratio), 
                 binwidth = 0.05) +
  theme_bw()

# get the data used to create the histogram and select columns of interest
ratio_plot_data <- ggplot_build(ratio_plot)$data[[1]]
ratio_plot_data <- select(ratio_plot_data, 
                          y, 
                          count, 
                          x, 
                          xmin, 
                          xmax, 
                          density)

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