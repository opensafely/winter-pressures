rm(list = ls())
#   for the SRO data,
# I would load up  measure_asthma_practice_only_rate.csv  and select cols date, practice_id, population
# I would load  measure_end_population_sro.csvand select cols date, practice_id, population_sro
# I would join the data on date, practice_id
# I would compare population and population_sro
# Then repeat for all SRO measures.
# Then apply similar logic to the appointments data. 

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

source(here("analysis", "metrics","src", "practice_population_filtering.R"))

#######################################################################
# source files
#######################################################################

percentage_threshold <- 10 # remove any practices that 
population_size_threshold <- 500

measure <- c("over12_appt_pop_rate",
             "under12_appt_pop_rate", 
             "over12_appt_rate",
             "under12_appt_rate",
             "sro")

list_practcies_to_remove <- lapply(measure, 
       get_practices_to_remove,
       percentage_threshold = percentage_threshold,
       population_size_threshold = population_size_threshold)

all_practices_to_remove <- unique(unlist(list_practcies_to_remove))
all_practices_to_remove <- tibble(practice = all_practices_to_remove)

print(paste0("Number of practices removed: ", nrow(all_practices_to_remove)))


#######################################################################
# save out practices to remove
#######################################################################

write.csv(all_practices_to_remove,
          file = "output/metrics/practices_to_remove.csv",
          row.names = FALSE)
