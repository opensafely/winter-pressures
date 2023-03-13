
metrics_directory <- here("output", "metrics")
appt_directory <- here("output", "appointments")

metrics_directory_shaded <- here("output", "metrics","shaded")
appt_directory_shaded <- here("output", "appointments","shaded")

measure_descriptions = tribble(
    ~long_name, ~description,
    "alt_practice_only_rate", "SRO Liver Function Testing - Alanine Transferaminase (ALT)",
    "asthma_practice_only_rate", "SRO Asthma Reviews",
    "cholesterol_practice_only_rate", "SRO Cholesterol Testing",
    "copd_practice_only_rate", "SRO Chronic Obstructive Pulmonary Disease (COPD) Reviews",
    "hba1c_practice_only_rate", "SRO Glycated Haemoglobin A1c Level (HbA1c)",
    "medication_review_practice_only_rate", "SRO Medication Reviews",
    "qrisk2_practice_only_rate", "SRO Cardiovascular Disease 10 year Risk Assessment (QRISK)",
    "rbc_practice_only_rate", "SRP Full Blood Count - Red Blood Cell (RBC) Testing",
    "sodium_practice_only_rate", "SRO Renal Function Assessment - Sodium Testing",
    "systolic_bp_practice_only_rate", "SRO Blood Pressure Monitoring",
    "tsh_practice_only_rate", "SRO Thyroid Testing",
    "over12_appt_pop_rate", "Rate of 12-15 year olds presenting (proportion of list size)",
    "over12_appt_rate", "Rate of 12-15 year olds presenting (proportion of 12-15 year olds)",
    "under12_appt_pop_rate", "Rate of 5-11 year olds presenting (proportion of list size)",
    "under12_appt_rate", "Rate of 5-11 year olds presenting (proportion of 5-11 year olds)",
    "monthly_median_lead_time_in_days_by_booked_month", "Appointments: median lead time (by booked month)",
    "monthly_median_lead_time_in_days_by_start_month", "Appointments: median lead time (by start month)",
    "monthly_num_appointments_by_booked_month", "Appointments: number of appointments (by booked month)",
    "monthly_num_appointments_by_start_month", "Appointments: number of appointments (by start month)",
    "monthly_num_unique_patients_by_booked_month", "Appointments: number of unique patients (by booked month)",
    "monthly_num_unique_patients_by_start_month", "Appointments: number of unique patients (by start month)",
    "monthly_normalised_num_appointments_by_booked_month", "Appointments: number of appointments normalised by list size (by booked month)",
    "monthly_normalised_num_appointments_by_start_month", "Appointments: number of appointments normalised by list size (by start month)",
    "monthly_normalised_num_unique_patients_by_booked_month", "Appointments: number of unique patients normalised by list size (by booked month)",
    "monthly_normalised_num_unique_patients_by_start_month", "Appointments: number of unique patients normalised by list size (by start month)",
    "monthly_proportion_lead_time_in_days_within_0days_by_booked_month", "Appointments: proportion of same day appointments (by booked month)",
    "monthly_proportion_lead_time_in_days_within_0days_by_start_month", "Appointments: proportion of same day appointments (by start month)",
    "monthly_proportion_lead_time_in_days_within_2days_by_booked_month", "Appointments: proportion of appointments within 2 days (by booked month)",
    "monthly_proportion_lead_time_in_days_within_2days_by_start_month", "Appointments: proportion of appointments within 2 days (by start month)"
) %>% mutate( short_name = long_name %>%
    str_remove( "_practice_only_rate$" ) %>%
    str_remove( "^monthly_" ) ) %>%
    select(short_name, long_name, everything() )

measure_to_description = function( m, use_short_name = FALSE ) {
    description = ""

    if ( use_short_name ) {
        description = measure_descriptions %>%
            filter(short_name == m) %>%
            pull(description)
    } else {
        description = measure_descriptions %>%
            filter(long_name == m) %>%
            pull(description)
    }

    return( description )
}

method_labels = list(
    seasonal_difference = "Percentage seasonal difference",
    seasonal_log2_ratio = "Seasonal difference (log2 ratio)"
)

method_formula = list(
    seasonal_difference = "100*(winter-summer)/summer",
    seasonal_log2_ratio = "log2(winter/summer)"
)

statistics_labels = list(
    description = "Metric",
    num = "Num practices",
    num_missing = "Num practices with missing data",
    num_infinite = "Num practices with infinite data",
    mean = "Mean",
    median = "Median",
    p05 = "5th centile",
    p95 = "95th centile",
    IQR = "IQR",
    Q1 = "Q1 (25th centile)",
    Q3 = "Q3 (75th centile)"
)

get_statistics_labels = function( x ) {
    labels = statistics_labels[x]
    missing_mask = names(statistics_labels[x]) %>% is.na()
    replacements = x[missing_mask] %>% str_to_title()
    labels[missing_mask] = replacements
    names(labels)[missing_mask] = x[missing_mask]
    return( labels %>% unlist )
}