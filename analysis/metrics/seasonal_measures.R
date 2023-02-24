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
# read in aggregated SRO season data
#######################################################################

sro_measure_name <- pull(
  read_csv(file = here("analysis", "metrics", "sro_measure_names.csv"),
           col_types = cols(
             sro_measure = col_character()
           )),
  sro_measure
)

invisible(lapply(sro_measure_name,
                 create_seasonal_sro_plots)
)

#######################################################################
# read in appointment season data
#######################################################################

appointment_measure_name <- pull(
  read_csv(file = here("analysis", "metrics", "appointments_measure_names.csv"),
           col_types = cols(
             appointment_measure = col_character()
           )),
  appointment_measure
)

invisible(lapply(appointment_measure_name,
                 create_seasonal_appointment_plots)
)

