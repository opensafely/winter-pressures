## Import libraries ----
library('tidyverse')
library('lubridate')
library('arrow')
library('here')
library('glue')
library('purrr')

source(here("analysis", "design.R"))


patient_outcomes <- read_feather(here("output", "epi", "input_epi.feather"))

deciles<-read_csv(here("output","combined","combined_seasonal_data_with_deciles.csv"))

##in dummy data replace practice IDs that exist in `deciles` but not in `patient_outcomes`
if ((Sys.getenv("OPENSAFELY_BACKEND") %in% c("", "expectations"))) {
  ### add any missing 5th deciles
  missing_5th_func <- function(df){
    missing_5th<-df %>% 
      group_by(variable) %>%
      filter(!(5 %in%  seasonal_difference_decile)) %>%
      select(variable) %>%
      unique()
    return(missing_5th)
  }
  
  missing_5th<-missing_5th_func(deciles)
  print("missing 5th deciles before replacement")
  print(missing_5th$variable)
  
  for (vari in missing_5th$variable){
    print(vari)
    deciles <- deciles %>%
      group_by(variable) %>%
      mutate(seasonal_difference_decile = case_when(variable==vari & row_number()==1 ~ 5,
                                                    TRUE~seasonal_difference_decile))
  }
  
  print("missing 5th deciles after replacement")
  print(missing_5th_func(deciles)$variable)
  
  
  practicetoreplace_func <- function(df){df<-deciles %>% 
    select(practice,seasonal_difference_decile,variable) %>%
    group_by(variable) %>%
    filter( seasonal_difference_decile==5 & !(practice  %in% patient_outcomes$practice) ) %>%
    unique() %>%
    droplevels()
    return(df)
  }
  practicetoreplace <-practicetoreplace_func("practicetoreplace")
  print("missing practices before replacement")
  print(practicetoreplace)
  for(var in practicetoreplace$variable){
    practicetoreplace_variable <- practicetoreplace %>% 
      filter(variable==var)
    
    deciles_variable <- deciles %>% 
      filter(variable==var)
    
    practicereplacement <-  patient_outcomes %>% 
      select(practice) %>% 
      filter(!practice  %in% deciles_variable$practice) %>% 
      unique()
    
    for (i in 1:length(unique(practicetoreplace_variable$practice))){
      deciles <- deciles %>% 
        mutate(practice = case_when(
          practice==as.numeric(unique(practicetoreplace_variable$practice)[i]) & variable == var ~ as.numeric(practicereplacement$practice[i]),
          TRUE ~ practice))
    } 
  }
  
  practicetoreplace <-practicetoreplace_func("practicetoreplace")
  print("missing practices after replacement")
  print(practicetoreplace)
}

deciles_wide<-deciles %>%
  select(practice,variable,seasonal_difference_decile) %>%
  pivot_wider(names_from = variable, values_from = seasonal_difference_decile)


irr_func <- function(measure,outcome){

  if( measure %in% sro_metrics){
    patient_outcomes_filtered <- patient_outcomes %>% filter(population_sro)
  } else if(
    length(grep('under12', measure)) > 0){
    patient_outcomes_filtered <- patient_outcomes %>% filter(population_under12)
  } else if(
    length(grep('over12', measure)) > 0){
    patient_outcomes_filtered <- patient_outcomes %>% filter(population_over12)
  } else {patient_outcomes_filtered <- patient_outcomes}
  
  patient_outcomes_filtered %>%
  mutate(across(ends_with("_date"), ~ as.Date(.)),
         admitted_or_emergency = pmin(emergency_date,admitted_unplanned_date,na.rm = T)
         )  %>%
  # because of a bug in cohort extractor -- remove once fixed
  mutate(patient_id = as.integer(patient_id)) %>%
  # filter(!!as.name(measure)) %>%
  select(!!as.name(outcome),dereg_date,end_date,start_date,practice) %>%
  left_join(
    deciles_wide %>% 
                summarise(decile = !!as.name(measure),
                          practice,.groups="keep")
            ,by = "practice") %>%
  drop_na(decile) %>%
  mutate(censor_date=  
           pmin(
             dereg_date,
             end_date,
             !!as.name(outcome),
             na.rm = TRUE
           ),
         events = ifelse(!!as.name(outcome)==censor_date,1,0),
         tte= censor_date- start_date
  )  %>%
  group_by(decile, start_date) %>%
  summarise(sum_tte = as.numeric(sum(tte)),
            sum_events = sum(events,na.rm = T),
            inc_rate = sum_events / sum_tte,
            .groups = "keep") %>%
   ungroup() %>%
   group_by(start_date) %>%
   mutate(irr= inc_rate /inc_rate[decile==5],
         irr.ln.se = sqrt((1 / sum_events) + (1 / sum_events[decile==5])),
         irr.ll = case_when(decile==5~irr,
         TRUE ~ exp(log(irr) + qnorm(0.025) * irr.ln.se)),
         irr.ul = case_when(decile==5~irr,
         TRUE ~ exp(log(irr) + qnorm(0.975) * irr.ln.se))
  ) %>%
    ungroup() 
}

irr_args <- expand.grid(metric = metrics,outcome =outcomes) 

irr_data<- irr_args %>% 
  mutate(
    data = map2(
      .x = as.character(metric),
      .y = as.character(outcome),
      .f = irr_func
  )) %>%
  unnest(data)

  write_csv(irr_data, here("output", "epi", "irr_data.csv"))
  