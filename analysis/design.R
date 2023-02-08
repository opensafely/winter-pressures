# # # # # # # # # # # # # # # # # # # # #
# This script:
# creates metadata for aspects of the study design
# # # # # # # # # # # # # # # # # # # # #

# Preliminaries ----

## Import libraries ----
library("tidyverse")
library("here")

## create output directories ----
fs::dir_create(here("lib", "design"))

# define key dates ----

study_dates <- lst(
    winter_dates = lst(
        start_date = "2021-12-01",
        end_date = "2022-03-30",
        ),
    summer_dates = lst(
        start_date = "2021-06-01",
        end_date = "2021-09-30",
        )
)