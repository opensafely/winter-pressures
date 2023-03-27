library(dplyr)
library(tidyr)
library(readr)
library(magrittr)
library(glue)
library(stringr)
library(here)
library(purrr)

source(here("analysis", "utils.R"))

target_dir = here("output", "metrics", "monthly")
target_pattern <- "measure_(.*)_practice_only_rate.csv"

target_files = list.files(
    path = target_dir,
    pattern = target_pattern,
    full.names = TRUE,
    recursive = TRUE
)

### Creating a directory to record which practices are not present
###  in either the raw counts or the population data
check_directory <- fs::dir_create(
    path = here("output", "practice-counts-check")
)

f_count = 0
practice_counts_store <- tibble()

for (f in target_files) {
    f_count <- f_count + 1

    cat(glue("[{f_count}] Reading in '{basename(f)}'\n\n"))

    this_metric = basename(f) %>%
        str_match(target_pattern) %>%
        last()

    d <- read_csv(f,
        col_types = cols_only(
            practice = col_integer(),
            date = col_date()
        )
    ) %>%
        group_by(date) %>%
        summarise(num_practices = length(unique(practice))) %>%
        mutate(metric = this_metric)

    if (nrow(practice_counts_store) == 0) {
        practice_counts_store = d
    } else {
        practice_counts_store = practice_counts_store %>% bind_rows(d)
    }
}

practice_counts_store_wide = practice_counts_store %>%
    pivot_wider(names_from = metric, values_from = num_practices) %>%
    mutate(max = select(., where(is.numeric)) %>% reduce(pmax, na.rm = T)) %>%
    mutate(min = select(., where(is.numeric)) %>% reduce(pmin, na.rm = T))
    

###  Write data file file
write.csv(practice_counts_store_wide,
    file = paste(check_directory,
        "practice-counts-for-metrics.csv",
        sep = "/"
    ), row.names = FALSE
)


