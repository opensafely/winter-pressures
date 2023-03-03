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

    d_normalised = normalise_raw_counts( d, listsizes )

    output_file = paste(output_dir,
        basename(f) %>% str_replace("num", "normalised_num"),
        sep = "/"
    )
    
    cat(glue("[{f_count}] Writing out '{basename(output_file)}'\n\n"))

    ###  Write data file
    write.csv(d_normalised, file = output_file, row.names=FALSE, quote=FALSE)

}