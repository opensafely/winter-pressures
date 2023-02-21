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

source(here("analysis", "metrics","src", "generate_seasonal_metrics.R"))

#######################################################################
# read in aggregated season data
#######################################################################

sro_measure_name <- "asthma"

season_data <- read_csv(file = here("output", 
                     "metrics", 
                     sro_measure_name,
                     "season_data.csv"),
                     col_types = cols(
                       practice = col_double(),
                       season = col_double(),
                       value = col_double(),
                       year = col_double()
                     ))

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
  geom_histogram(aes(x=seasonal_log2_ratio), 
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

output_directory <- here("output", 
                         "metrics", 
                         sro_measure_name)

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
