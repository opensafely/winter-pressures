library(dplyr)
library(readr)
library(magrittr)
library(glue)
library(stringr)
library(here)

source(here("analysis", "utils.R"))

listsize_file = here("output", "listsize", "measure_listsize.csv")

listsizes = read_csv(listsize_file,
    col_types = cols_only(
        practice = col_integer(),
        population = col_double(),
        date = col_date()
    )
)

target_dir = here("output", "appointments")
target_pattern = "measure_monthly_num_.*.csv"

listsize_directory = here("output", "listsize")

target_files = list.files(
    path = target_dir,
    pattern = target_pattern,
    full.names = TRUE,
    recursive = TRUE
)

output_dir = target_dir

### Creating a directory to record which practices are not present
### in either the raw counts or the population data
check_directory <- fs::dir_create(
    path = here("output", "check")
)

f_count = 0

for (f in target_files) {
    f_count = f_count + 1
    
    d = read_csv(f,
        col_types = cols_only(
            practice = col_integer(),
            value = col_integer(),
            date = col_date()
        )
    ) %>% rename( raw_count = value )

    cat(glue("[{f_count}] Reading in '{basename(f)}'\n\n"))

    out = normalise_raw_counts(d, listsizes)
    
    ### == Recording the normalised counts ==========================

    d_normalised = out$normalised
    
    output_file = paste(output_dir,
        basename(f) %>% str_replace("num", "normalised_num"),
        sep = "/"
    )
    
    cat(glue("[{f_count}] Writing out '{basename(output_file)}'\n\n"))

    write.csv(d_normalised, file = output_file, row.names=FALSE, quote=FALSE)

    ### == Recording practices with raw counts missing ==============

    d_raw_counts_missing = out$raw_counts_missing 

    raw_counts_check_file = paste(check_directory,
        basename(f) %>%
            str_replace("num", "normalised_num") %>%
            str_replace(".csv","_RAW-COUNT-CHECK.csv"),
        sep = "/"
    )

    cat(glue("[{f_count}] Writing out {nrow(d_raw_counts_missing)} records with raw counts missing\n\n"))

    write.csv(d_raw_counts_missing, file = raw_counts_check_file, row.names = FALSE, quote = FALSE)


    ### == Recording practices with population missing ==============

    d_population_missing <- out$population_missing 

    population_check_file <- paste(check_directory,
        basename(f) %>%
            str_replace("num", "normalised_num") %>%
            str_replace(".csv", "_POPULATION-CHECK.csv"),
        sep = "/"
    )

    cat(glue("[{f_count}] Writing out {nrow(d_population_missing)} records with population missing\n\n"))

    ###  Write data file
    write.csv(d_population_missing, file = population_check_file, row.names = FALSE, quote = FALSE)


}