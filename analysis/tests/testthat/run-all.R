library(testthat, quietly = T, warn.conflicts = FALSE)
library(here)
library(tidyr)
library(dplyr)
library(lubridate)

source(here("analysis", "utils.R"))

log_file <- here("output", "tests", "run-all.log")
output_dir <- here("output", "tests")

dir.create(output_dir, showWarnings = FALSE)

sink(log_file)
on.exit(sink())
test_dir(here("analysis", "tests", "testthat"))