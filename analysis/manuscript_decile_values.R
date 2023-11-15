####################################################################
# libraries
####################################################################

library(tidyverse)

####################################################################
# read in data
####################################################################

data_filepath <- c(
  "output/deciles_table_monthly_median_lead_time_in_days_by_booked_month.csv",
  "output/deciles_table_monthly_normalised_num_appointments_by_booked_month.csv",
  "output/deciles_table_monthly_proportion_lead_time_in_days_within_0days_by_booked_month.csv",
  "output/deciles_table_monthly_proportion_lead_time_in_days_within_2days_by_booked_month.csv",
  "output/deciles_table_over12_appt_rate.csv",
  "output/deciles_table_under12_appt_rate.csv"
)

label <- c("Median lead time (days)",
           "Average number of appointments per patient",
           "Proportion of same day appointments",
           "Proportion of appointments within 2 days",
           "Appointment rate (12-15 year olds)",
           "Appointment rate (5-12 year olds)"
)

####################################################################
# read in data
####################################################################

####################################################################
# Median lead time
####################################################################


####################################################################
# Average number of appointments per patient
####################################################################


dat <- read_csv(data_filepath[2]) %>%
  tibble() %>%
  mutate(percentile = as.integer(percentile)) %>%
  filter( percentile %in% seq(10, 90, by = 10)) %>%
  filter(date <= as.Date("2022-05-01")) 

# median
dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(max(value))  



####################################################################
# Proportion of same day appointments
####################################################################

dat <- read_csv(data_filepath[3]) %>%
  tibble() %>%
  mutate(percentile = as.integer(percentile)) %>%
  filter( percentile %in% seq(10, 90, by = 10)) %>%
  filter(date <= as.Date("2022-05-01")) 

# median
dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(max(value))  



####################################################################
# Proportion of appointments within 2 days
####################################################################

dat <- read_csv(data_filepath[4]) %>%
  tibble() %>%
  mutate(percentile = as.integer(percentile)) %>%
  filter( percentile %in% seq(10, 90, by = 10)) %>%
  filter(date <= as.Date("2022-05-01")) 

# median
dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(max(value))  

# 1st decile
dat %>%
  filter(percentile == 10) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 10) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 10) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 10) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(max(value))  

# 9th decile
dat %>%
  filter(percentile == 90) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 90) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 90) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 90) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(max(value))  


####################################################################
# Appointment rate (12-15 year olds)
####################################################################

dat <- read_csv(data_filepath[5]) %>%
  tibble() %>%
  mutate(percentile = as.integer(percentile)) %>%
  filter( percentile %in% seq(10, 90, by = 10)) %>%
  filter(date <= as.Date("2022-05-01")) 

# median
dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(max(value))  

####################################################################
# Appointment rate (5-12 year olds)
####################################################################


dat <- read_csv(data_filepath[6]) %>%
  tibble() %>%
  mutate(percentile = as.integer(percentile)) %>%
  filter( percentile %in% seq(10, 90, by = 10)) %>%
  filter(date <= as.Date("2022-05-01")) 

# median
dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date <= as.Date("2020-02-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date > as.Date("2020-02-01")) %>%
  filter(date < as.Date("2020-08-01")) %>%
  summarise(max(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(min(value))

dat %>%
  filter(percentile == 50) %>%
  filter(date >= as.Date("2020-08-01")) %>%
  summarise(max(value))  
