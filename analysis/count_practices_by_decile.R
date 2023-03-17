library(dplyr)
library(tidyr)
library(readr)
library(magrittr)
library(glue)
library(stringr)
library(here)

source(here("analysis", "utils.R"))

file_directory = here( "output", "combined" )
input_file = "combined_seasonal_data_with_deciles.csv"

input_data = paste(
    file_directory, input_file,
    sep = "/" ) %>%
    read_csv() %>% 
    select( practice, year, variable, ends_with("decile") )

practice_counts = input_data %>%
    pivot_longer(
        cols = starts_with("seasonal"),
        names_to = "method",
        values_to = "decile" ) %>%
    mutate( method = str_remove( method, "_decile" ) ) %>%
    group_by( variable, year, method ) %>%
    summarise( num_practices = length( unique(practice) ) )

### Create output directory
output_directory <- fs::dir_create(
    path = here("output","combined")
)

### Write data file file
output_file = "practice_counts_per_decile.csv"
write.csv(practice_counts,
    file = paste(output_directory,
    output_file = output_file,
        sep = "/"
    ),
    row.names=FALSE
)
