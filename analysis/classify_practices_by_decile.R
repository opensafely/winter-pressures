library(dplyr)
library(tidyr)
library(readr)
library(magrittr)
library(glue)
library(stringr)
library(here)

source(here("analysis", "utils.R"))

output_directory = here( "output", "combined" )
output_file = "combined_seasonal_data.csv"

combined_data = paste(
    output_directory, output_file,
    sep = "/"
) %>%
    read_csv()

combined_data_with_deciles = calculate_seasonal_deciles_across_years_and_variables(combined_data)

combined_data_with_deciles_wide = combined_data_with_deciles %>%
    pivot_wider(
        id_cols = c("practice", "year", "variable"),
        names_from = "method",
        values_from = c("value","decile")
    ) %>%
    select(practice, year, starts_with("value"), starts_with("decile"), variable)

colnames(combined_data_with_deciles_wide) = lapply(colnames(combined_data_with_deciles_wide), column_edit)

### Create output directory
output_directory <- fs::dir_create(
    path = here("output","combined")
)

### Write data file file
write.csv(combined_data_with_deciles_wide,
    file = paste(output_directory,
        "combined_seasonal_data_with_deciles.csv",
        sep = "/"
    ),
    row.names=FALSE
)
