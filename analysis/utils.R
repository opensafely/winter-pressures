
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

mround <- function(x,base){
	base*round(x/base)
}

redact_and_round <- function(d, redact_below = 5, round_to = 5, redaction_string="[REDACTED]") {
    d_nondisclosive = d
    d_nondisclosive[d_nondisclosive < redact_below] <- NA
    d_nondisclosive <- mround(d_nondisclosive, round_to)
    d_nondisclosive = replace_na(d_nondisclosive, redaction_string)
    return(d_nondisclosive)
}

normalise_raw_counts = function(raw_counts, practice_populations) {

    counts_normalised <- raw_counts %>%
        inner_join(practice_populations, by = c("date", "practice")) %>%
        mutate( value = raw_count / population ) %>%
        select(value, date, practice)

    population_missing <- raw_counts %>%
        anti_join(practice_populations, by = c("date", "practice"))

    raw_counts_missing <- practice_populations %>%
        anti_join(raw_counts, by = c("date", "practice"))
    

    return(list(
        normalised = counts_normalised,
        raw_counts_missing = raw_counts_missing,
        population_missing = population_missing
    ))

}
