
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

source(here("analysis", "metrics", "src", "sro_data_wrangling.R"))

#######################################################################
# define the seasons
#######################################################################

# define the months associated with each season
# summer: June - September inclusive
# winter: December - March inclusive
summer_months <- c(6:9)
winter_months <- c(1:3, 12)
# need to check the season lengths are the same


#######################################################################
# define the SRO measures
#######################################################################

measure_name <- pull(
  read_csv(file = here("output", "metrics", "sro_measure_names.csv"),
           col_types = cols(
             sro_measure = col_character()
           )),
  sro_measure
)

#######################################################################
# create season aggregated SRO measure data
#######################################################################

# read in SRO measure data
# aggregate data to season by practice and seasonal year
# calculate the value (proportion)
# output to a csv
# seasons: summer is 0, winter is 1

invisible(lapply(measure_name,
                 get_season_aggregate_sro_measure,
                 summer_months = summer_months,
                 winter_months = winter_months)
)
