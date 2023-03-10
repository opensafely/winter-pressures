## Import libraries ----
library('tidyverse')
library('lubridate')
library('arrow')
library('here')
library('glue')


source(here("analysis", "design.R"))


outdir <- here("output", "epi")

patient_outcomes <- read_feather(here(outdir,"input_epi.feather"))

# TODO remove once we are happy with deciles outputs
# # create dummy practice deciles
# practices<-outcomes %>%
#   distinct(practice) %>%
#   mutate(decile = ntile(practice, 10))

deciles<-read_csv(here("output","combined","combined_seasonal_data_with_deciles.csv")) %>%
  select(practice,variable,seasonal_difference_decile) %>%
  pivot_wider(names_from = variable, values_from = seasonal_difference_decile) %>%
  # TODO fix the following selection of decile
  mutate(decile = alt) %>%
  drop_na(decile)



irr <- patient_outcomes %>%
  mutate(across(ends_with("_date"), ~ as.Date(.)),
         admitted_or_emergency = pmin(emergency_date,admitted_unplanned_date,na.rm = T)
         )  %>%
  # because of a bug in cohort extractor -- remove once fixed
  mutate(patient_id = as.integer(patient_id)) %>%
  filter(population_sro) %>%
  pivot_longer(
    cols = ends_with("death_date"),
    names_to = "outcome",
    values_to = "outcome_date",
    values_drop_na = F
  ) %>%
  mutate(censor_date=  
           pmin(
             dereg_date,
             end_date,
             outcome_date,
             na.rm = TRUE
           ),
         events = ifelse(outcome_date==censor_date,1,0),
         tte= censor_date- start_date
  ) %>%
  left_join(deciles) %>%
  # TODO move selection of decile variable to this point
  group_by(decile, start_date,outcome) %>%
  summarise(sum_tte = as.numeric(sum(tte)),
            sum_events = sum(events,na.rm = T),
            inc_rate = sum_events / sum_tte) %>%
  group_by(start_date,outcome) %>%
  mutate(irr= inc_rate /inc_rate[decile==5],
         # TODO fix limits calculations
         irr.ln.se = sqrt((1 / sum_events) + (1 / sum_events[decile==5])),
         irr.ll = exp(log(irr) + qnorm(0.025) * irr.ln.se),
         irr.ul = exp(log(irr) + qnorm(0.975) * irr.ln.se)
  )


  write_csv(irr,here(outdir,"irr_data.csv"))
