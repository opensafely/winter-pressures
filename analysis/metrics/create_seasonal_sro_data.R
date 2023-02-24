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
# read in SRO measure names
#######################################################################

measure_name <- pull(
  read_csv(file = here("analysis", "metrics", "sro_measure_names.csv"),
           col_types = cols(
             sro_measure = col_character()
           )),
  sro_measure
)

#######################################################################
# create season aggregated SRO measure data
#######################################################################

# read in SRO measure data
# assign a season and a year
# output to a csv
# seasons: summer is 0, winter is 1

invisible(lapply(measure_name,
                 get_season_aggregate_sro_measure)
)
