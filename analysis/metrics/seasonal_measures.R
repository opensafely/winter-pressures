#######################################################################
# load libraries
#######################################################################

library(tidyverse)
library(here)
library(dplyr)
library(ggplot2)
library(lubridate)
library(glue)

#######################################################################
# source files
#######################################################################

source(here("analysis","utils.R"))
source(here("analysis", "metrics","src", "generate_seasonal_metrics.R"))

print_title = function(m) {
  cat(paste(rep.int("=", 70), collapse = ""))
  cat("\n")
  cat(glue("Processing measure: {m}\n\n"))
  cat(paste(rep.int("-", 70), collapse = ""))
  cat("\n")
}

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

invisible(lapply(
  sro_measure_name,
  create_seasonal_sro_plots
))


# for (m in sro_measure_name) {
#   print_title(m)
#   tryCatch(
#     expr ={ create_seasonal_sro_plots(m) },

#     error=function(cond) {
#       message(glue("There was an error creating seasonal measures for the {m} data"))
#       message(glue("[ERROR]>> {cond}"))
#     },

#     warning=function(cond) {
#       message(glue("There was a warning creating seasonal measures for the {m} data"))
#       message(glue("[WARNING]>> {cond}"))
#     },
    
#     finally = {}
#   )
# }

#######################################################################
# read in kids appointment season data
#######################################################################

kids_measure_name <- pull(
  read_csv(file = here("analysis", "metrics", "kids_appt_measure_names.csv"),
           col_types = cols(
             kids_appt_measure = col_character()
           )),
  kids_appt_measure
)

invisible(lapply(kids_measure_name,
                 create_seasonal_kids_plots)
)

# for (m in kids_measure_name) {
#   print_title(m)
#   tryCatch(
#     expr = {
#       create_seasonal_kids_plots(m)
#     },
#     error = function(cond) {
#       message(glue("There was an error creating seasonal measures for the {m} data"))
#       message(glue("[ERROR]>> {cond}"))
#     },
#     warning = function(cond) {
#       message(glue("There was a warning creating seasonal measures for the {m} data"))
#       message(glue("[WARNING]>> {cond}"))
#     },
#     finally = {}
#   )
# }


#######################################################################
# read in appointment season data
#######################################################################

appointment_measure_name <- pull(
  read_csv(file = here("analysis", "appointments", "appointments_measure_names.csv"),
           col_types = cols(
             appointment_measure = col_character()
           )),
  appointment_measure
)

invisible(lapply(appointment_measure_name,
                 create_seasonal_appointment_plots)
)


# for (m in appointment_measure_name) {
#   print_title(m)
#   tryCatch(
#     expr = {
#       create_seasonal_appointment_plots(m)
#     },
#     error = function(cond) {
#       message(glue("There was an error creating seasonal measures for the {m} data"))
#       message(glue("[ERROR]>> {cond}"))
#     },
#     warning = function(cond) {
#       message(glue("There was a warning creating seasonal measures for the {m} data"))
#       message(glue("[WARNING]>> {cond}"))
#     },
#     finally = {}
#   )
# }

