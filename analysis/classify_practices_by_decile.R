library(dplyr)
library(tidyr)
library(readr)
library(magrittr)
library(glue)
library(stringr)
library(here)

output_directory = here( "output", "combined" )
output_file = "combined_seasonal_data.csv"

combined_data = paste(
    output_directory, output_file,
    sep = "/"
) %>%
    read_csv() %>%
    select( -X1 )

combined_data_with_deciles = combined_data


calculate_deciles = function( d, num_quantiles = 10 ) {
    return( ntile( d, num_quantiles ))
}

calculate_seasonal_deciles_across_years_and_variables = function(data) {

    data_long = data %>%
        pivot_longer(
            cols = starts_with("seasonal"),
            names_to = "method",
            values_to = "value"
        )

    data_with_deciles = data_long %>%
        group_by(year, variable, method) %>%
        mutate(decile = calculate_deciles(value))

    return( data_with_deciles )
}

column_edit = function(s) {
    new_s = s %>% str_remove("^value_")

    if ( s %>% str_detect("^decile_" ) ) {
        new_s = new_s %>% str_remove("^decile_")
        new_s = glue( "{new_s}_decile" )
    }
    return( new_s )
}

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
    )
)
