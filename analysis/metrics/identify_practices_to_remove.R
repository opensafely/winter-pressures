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
population_size_threshold <- 1000

measure <- c("over12_appt_pop_rate",
             "under12_appt_pop_rate", 
             "over12_appt_rate",
             "under12_appt_rate",
             "sro")

list_practices_to_remove <- lapply(measure, 
       get_practices_to_remove,
       percentage_threshold = percentage_threshold,
       population_size_threshold = population_size_threshold)

all_practices_to_remove <- unique(unlist(list_practices_to_remove))
all_practices_to_remove <- tibble(practice = all_practices_to_remove)

print(paste0("Number of practices removed: ", nrow(all_practices_to_remove)))


#######################################################################
# save out practices to remove
#######################################################################

write.csv(all_practices_to_remove,
          file = "output/metrics/practices_to_remove.csv",
          row.names = FALSE)
