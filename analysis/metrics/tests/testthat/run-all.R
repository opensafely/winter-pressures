library(testthat, quietly = T, warn.conflicts = FALSE)
library(here)
library(tidyr)
library(dplyr)

source( here("analysis", "metrics", "src", "generate_seasonal_metrics.R") )
source( here("analysis", "metrics", "src", "sro_data_wrangling.R") )

log_file <- here("output", "metrics", "tests", "run-all.log")
output_dir <- here("output", "metrics", "tests")

dir.create(output_dir, showWarnings = FALSE)

sink(log_file)
on.exit(sink())
test_dir( here("analysis", "metrics", "tests", "testthat") )
