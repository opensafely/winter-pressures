
### Purpose: To gather level 4 files ("moderately sensitive")
### place in a single directory for easy review and release
### Big thanks to @wjchulme for the useful script!

## Import libraries ----
library(tidyverse)
library(here)
library(glue)
library(lubridate)

ghere <- function(...) {
    here::here(glue::glue(..., .sep = .Platform$file.sep))
}

## post-matching ----
output_dir = ghere("output", glue("release"))

fs::dir_create(output_dir)

#####################################################################
### Report 
#####################################################################

fs::file_copy(
    ghere("output", "docs", "preliminary_report.html"),
    fs::path(output_dir, "preliminary_report.html"),
    overwrite = TRUE
)

#####################################################################
### Decile plots
#####################################################################

deciles_output_dir <- ghere(
    "output",
    "release",
    "decile-plots"
)

fs::dir_create(deciles_output_dir)

### --- for appointments --------------------------------------------
appointment_decile_files = list.files(
    ghere("output", "appointments", "shaded"),
    pattern = "deciles_(table|chart)_.*\\..*"
)

for ( f in appointment_decile_files ) {
    fs::file_copy(
        ghere("output", "appointments", "shaded", f),
        fs::path(deciles_output_dir, f),
        overwrite = TRUE
    )
}

### --- for other metrics -------------------------------------------
metrics_decile_files = list.files(
    ghere("output", "metrics", "shaded"),
    pattern = "deciles_(table|chart)_.*\\..*"
)

for (f in metrics_decile_files) {
    fs::file_copy(
        ghere("output", "metrics", "shaded", f),
        fs::path(deciles_output_dir, f),
        overwrite = TRUE
    )
}

#####################################################################
### Seasonal comparison histograms 
#####################################################################

seasonal_comparison_output_dir <- ghere(
    "output",
    "release",
    "seasonal-comparisons"
)

fs::dir_create(seasonal_comparison_output_dir)

target_file = "summer_winter_ratio_histogram.*redacted\\..*"

seasonal_comparison_histograms <- list.files(
    path = ghere("output"),
    pattern = target_file,
    full.names = TRUE,
    recursive = TRUE
)

for (f in seasonal_comparison_histograms ) {
    f_dir = dirname(f)
    f_file = basename(f)
    measure_string = f_dir %>% str_remove("/redacted") %>% basename()

    fs::file_copy(
        f,
        fs::path(seasonal_comparison_output_dir, glue("{measure_string}_{f_file}")),
        overwrite = TRUE
    )
}

#####################################################################
### Seasonal summaries for all metrics
#####################################################################

seasonal_summary_output_dir <- ghere(
    "output",
    "release",
    "seasonal-summary"
)

fs::dir_create(seasonal_summary_output_dir)

summaries_file = ghere("output", "combined", "seasonal_summaries_nondisclosive.csv")

fs::file_copy(
    summaries_file,
    fs::path(seasonal_comparison_output_dir, basename(summaries_file) ),
    overwrite = TRUE
)

#####################################################################
### Epi IRR plots 
#####################################################################

epi_output_dir <- ghere(
    "output",
    "release",
    "epi"
)

fs::dir_create(epi_output_dir)

target_file = ".*_combined.png"

epi_plots <- list.files(
    path = ghere("output","epi","plots","combined"),
    pattern = target_file,
    full.names = TRUE
)

for (f in epi_plots ) {
    f_dir = dirname(f)
    f_file = basename(f)

    fs::file_copy(
        f,
        fs::path(epi_output_dir, glue("{f_file}")),
        overwrite = TRUE
    )
}

epi_data = ghere("output", "epi", "irr_data.csv")

fs::file_copy(
    epi_data,
    fs::path(epi_output_dir, basename(epi_data) ),
    overwrite = TRUE
)


#####################################################################
### Create some meta release files
#####################################################################

fs::dir_create(here("output", "meta-release"))

## create text for output review issue ----
fs::dir_ls(output_dir, type = "file", recurse = TRUE) %>%
    map_chr(~ str_remove(., fixed(here()))) %>%
    map_chr(~ paste0("- [ ] ", str_remove(., fixed("/")))) %>%
    paste(collapse = "\n") %>%
    writeLines(here("output", "meta-release", "files-for-release.txt"))

## create command for releasing using osrelease ----
fs::dir_ls(output_dir, type = "file", recurse = TRUE) %>%
    map_chr(~ str_remove(., fixed(here()))) %>%
    # map_chr(~paste0("'",. ,"'")) %>%
    paste(., collapse = " ") %>%
    paste("osrelease", .) %>%
    writeLines(here("output", "meta-release", "osrelease-command.txt"))