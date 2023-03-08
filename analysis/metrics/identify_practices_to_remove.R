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

# find practices with small population from only 1 measure
practices_with_small_population <- get_practices_to_remove(
  percentage_threshold = percentage_threshold,
  population_size_threshold = population_size_threshold,
  practice_removal_criterion = "small_population",
  measure = "over12_appt_pop_rate")

# find practices with population change over all measures
list_practices_with_population_change <- lapply(measure, 
       get_practices_to_remove,
       percentage_threshold = percentage_threshold,
       population_size_threshold = population_size_threshold,
       practice_removal_criterion = "large_population_change")

practices_with_population_change <- unique(unlist(list_practices_with_population_change))

# combine the practices with small population and with large population change
all_practices_to_remove <- tibble(practice = unique(c(practices_with_population_change,
                                                      practices_with_small_population)
)
)

print(paste0("Number of practices removed: ", nrow(all_practices_to_remove)))


#######################################################################
# save out practices to remove
#######################################################################

write.csv(all_practices_to_remove,
          file = "output/metrics/practices_to_remove.csv",
          row.names = FALSE)
