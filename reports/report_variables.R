measure_descriptions = tribble(
    ~name, ~description,
    "alt_practice_only_rate", "Liver Function Testing - Alanine Transferaminase (ALT)",
    "asthma_practice_only_rate", "Asthma Reviews",
    "cholesterol_practice_only_rate", "Cholesterol Testing",
    "copd_practice_only_rate", "Chronic Obstructive Pulmonary Disease (COPD) Reviews",
    "hba1c_practice_only_rate", "Glycated Haemoglobin A1c Level (HbA1c)",
    "medication_review_practice_only_rate", "Medication Reviews",
    "qrisk2_practice_only_rate", "Cardiovascular Disease 10 year Risk Assessment (QRISK)",
    "rbc_practice_only_rate", "Full Blood Count - Red Blood Cell (RBC) Testing",
    "sodium_practice_only_rate", "Renal Function Assessment - Sodium Testing",
    "systolic_bp_practice_only_rate", "Blood Pressure Monitoring",
    "tsh_practice_only_rate", "Thyroid Testing",
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
    "monthly_proportion_lead_time_in_days_within_0days_by_booked_month", "Proportion same day appointments (by booked month)",
    "monthly_proportion_lead_time_in_days_within_0days_by_start_month", "Proportion same day appointments (by start month)",
    "monthly_proportion_lead_time_in_days_within_2days_by_booked_month", "Proportion appointments within 2 days (by booked month)",
    "monthly_proportion_lead_time_in_days_within_2days_by_start_month", "Proportion appointments within 2 days (by start month)"
)

measure_to_description = function( m ) {
    return(measure_descriptions %>% filter( name == m ) %>% pull( description ))
}