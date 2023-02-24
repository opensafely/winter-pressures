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

measure_name <- pull(
  read_csv(file = here("analysis", "metrics", "sro_measure_names.csv"),
           col_types = cols(
             sro_measure = col_character()
           )),
  sro_measure
)

invisible(lapply(measure_name,
                 create_seasonal_sro_plots)
)
