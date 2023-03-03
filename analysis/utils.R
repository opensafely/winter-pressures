normalise_raw_counts = function(raw_counts, practice_populations) {

    counts_normalised <- raw_counts %>%
        left_join(practice_populations, by = c("date", "practice")) %>%
        mutate( value = raw_count / population ) %>%
        select(value, date, practice)

    return( counts_normalised )

}