
metrics_directory <- here("output", "metrics")
appt_directory <- here("output", "appointments")

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
    "monthly_median_lead_time_in_days_by_booked_month", "Median lead time (by booked month)",
    "monthly_median_lead_time_in_days_by_start_month", "Median lead time (by start month)",
    "monthly_num_appointments_by_booked_month", "Number of appointments (by booked month)",
    "monthly_num_appointments_by_start_month", "Number of appointments (by start month)",
    "monthly_num_unique_patients_by_booked_month", "Number of unique patients (by booked month)",
    "monthly_num_unique_patients_by_start_month", "Number of unique patients (by start month)",
    "monthly_normalised_num_appointments_by_booked_month", "Number of appointments normalised by list size (by booked month)",
    "monthly_normalised_num_appointments_by_start_month", "Number of appointments normalised by list size (by start month)",
    "monthly_normalised_num_unique_patients_by_booked_month", "Number of unique patients normalised by list size (by booked month)",
    "monthly_normalised_num_unique_patients_by_start_month", "Number of unique patients normalised by list size (by start month)",
    "monthly_proportion_lead_time_in_days_within_0days_by_booked_month", "Proportion of same day appointments (by booked month)",
    "monthly_proportion_lead_time_in_days_within_0days_by_start_month", "Proportion of same day appointments (by start month)",
    "monthly_proportion_lead_time_in_days_within_2days_by_booked_month", "Proportion of appointments within 2 days (by booked month)",
    "monthly_proportion_lead_time_in_days_within_2days_by_start_month", "Proportion of appointments within 2 days (by start month)"
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