# # # # # # # # # # # # # # # # # # # # #
# This script:
# creates metadata for aspects of the study design
# # # # # # # # # # # # # # # # # # # # #

# Preliminaries ----

## Import libraries ----
library("tidyverse")
library("here")

## create output directories ----
fs::dir_create(here("lib", "design"))

# define key dates ----

study_dates <- lst(
    winter_dates = lst(
        start_date = "2021-12-01",
        end_date = "2022-03-30",
        ),
    summer_dates = lst(
        start_date = "2021-06-01",
        end_date = "2021-09-30",
        )
)

sro_metrics <- list(c("alt","asthma","cholesterol","copd","hba1c","medication_review","qrisk2","rbc","sodium",
                    "systolic_bp","tsh"))[[1]]      

metrics <- list(c("median_lead_time_in_days_by_booked_month","median_lead_time_in_days_by_start_month",
                "num_appointments_by_booked_month","num_appointments_by_start_month","num_unique_patients_by_booked_month",
                "num_unique_patients_by_start_month","proportion_lead_time_in_days_within_0days_by_booked_month",
                "proportion_lead_time_in_days_within_0days_by_start_month","proportion_lead_time_in_days_within_2days_by_booked_month",
                "proportion_lead_time_in_days_within_2days_by_start_month","alt","asthma","cholesterol","copd","hba1c",
                "medication_review","over12_appt_pop_rate","over12_appt_rate","qrisk2","rbc","sodium","systolic_bp","tsh",
                "under12_appt_pop_rate","under12_appt_rate"))[[1]]

outcomes <- list(c("death_date","icd1_death_date","icd2_death_date","icd3_death_date",
              "icd4_death_date","icd5_death_date","icd6_death_date","icd7_death_date",
              "icd8_death_date","icd9_death_date","icd10_death_date","icd11_death_date",
              "icd12_death_date","icd13_death_date","icd14_death_date","icd15_death_date",
              "icd16_death_date","icd17_death_date","icd18_death_date","icd19_death_date",
              "icd20_death_date","icd21_death_date","icd22_death_date","emergency_date",
              "admitted_unplanned_date","admitted_or_emergency"))[[1]]

