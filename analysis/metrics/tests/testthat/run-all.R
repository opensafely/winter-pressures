library(testthat, quietly = T, warn.conflicts = FALSE)
library(here)
library(tidyr)
library(dplyr)

source( here("analysis", "metrics", "src", "generate_seasonal_metrics.R") )

log_file <- here("output", "metrics", "tests", "run-all.log")
output_dir <- here("output", "metrics", "tests")

dir.create(output_dir, showWarnings = FALSE)

sink( log_file )
test_dir( here("analysis", "metrics", "tests", "testthat") )
sink( NULL )