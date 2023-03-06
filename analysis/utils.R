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

redact_and_round <- function(d, redact_below = 5, round_to = 5) {
    d_nondisclosive = d
    d_nondisclosive[d_nondisclosive < redact_below] <- NA
    d_nondisclosive <- plyr::round_any(d_nondisclosive, round_to)
    return(d_nondisclosive)
}