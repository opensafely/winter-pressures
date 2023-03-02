library(dplyr)
library(tidyr)
library(readr)
library(magrittr)
library(glue)
# library(stringr)
library(here)

output_directory = here( "output", "combined" )
output_file = "combined_seasonal_data.csv"

combined_data = paste(
    output_directory, output_file,
    sep = "/"
) %>%
    read_csv() %>%
    select( -X1 )

summary_methods = combined_data %>%
    select(starts_with("seasonal")) %>%
    colnames

measures = combined_data %>%
    pull(variable) %>%
    unique()

years = combined_data %>%
    pull(year) %>%
    unique()

combined_data_with_deciles = combined_data

add_decile = function(d,value_column,num_quantiles=10){
    decile_column = glue("{value_column}_decile")

    d_converted = d %>%
        mutate({{ decile_column }} := ntile(!!as.name(value_column), num_quantiles))
    
    return ( d_converted )
}


for (this_summary_method in summary_methods) {
    this_summary_data = combined_data %>%
        select(practice, year, {{ this_summary_method }}, variable)

    this_decile_holder = tibble()

    for (this_year in years) {
        for (this_measure in measures) {
            this_measure_data = this_summary_data %>%
                filter(year == this_year & variable == this_measure)

            converted_measure_data = add_decile(
                d = this_measure_data,
                value_column = this_summary_method,
                num_quantiles = 10
            )

            this_decile_holder = this_decile_holder %>% bind_rows(converted_measure_data)
        }
    }

    combined_data_with_deciles = combined_data_with_deciles %>%
        left_join(this_decile_holder, by = c("practice", "year", "variable", this_summary_method))
}

combined_data_with_deciles = combined_data

add_decile = function(d,value_column,num_quantiles=10){
    decile_column = glue("{value_column}_decile")

    d_converted = d %>%
        mutate({{ decile_column }} := ntile(!!as.name(value_column), num_quantiles))
    
    return ( d_converted )
}


for (this_summary_method in summary_methods) {
    this_summary_data = combined_data %>%
        select(practice, year, {{ this_summary_method }}, variable)

    this_decile_holder = tibble()

    for (this_year in years) {
        for (this_measure in measures) {
            this_measure_data = this_summary_data %>%
                filter(year == this_year & variable == this_measure)

            converted_measure_data = add_decile(
                d = this_measure_data,
                value_column = this_summary_method,
                num_quantiles = 10
            )

            this_decile_holder = this_decile_holder %>% bind_rows(converted_measure_data)
        }
    }

    combined_data_with_deciles = combined_data_with_deciles %>%
        left_join(this_decile_holder, by = c("practice", "year", "variable", this_summary_method))
}

column_order = c(
    "practice", "year",
    c(summary_methods, glue("{summary_methods}_decile")) %>% sort,
    "variable" )

combined_data_with_deciles = combined_data_with_deciles %>%
    select( !!! column_order )

### Create output directory
output_directory <- fs::dir_create(
    path = here("output","combined")
)

### Write data file file
write.csv(combined_data_with_deciles,
    file = paste(output_directory,
        "combined_seasonal_data_with_deciles.csv",
        sep = "/"
    )
)
