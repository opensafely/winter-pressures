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

make_plots <- function(filepath,
                       y_axis_label){
  
  dat <- read_csv(filepath) %>%
    tibble() %>%
    mutate(percentile = as.integer(percentile)) %>%
    filter( percentile %in% seq(10, 90, by = 10)) %>%
    filter(date <= as.Date("2022-05-01"))
  
  ggplot() +
    geom_line(data = dat %>% filter(percentile == 50),
              aes(
                x = date,
                y = value,
                group = percentile
              ),
              alpha = 1, 
              colour = "#0000FF",
              size = 0.8) +
    geom_line(data = dat %>% filter(percentile != 50),
              aes(
                x = date,
                y = value,
                group = percentile
              ),
              alpha = 0.5, 
              colour = "#0000FF",
              linetype = "dashed") +
    theme_bw() +
    scale_x_date(breaks = seq(as.Date(min(dat$date)),
                              as.Date(max(dat$date)),
                              by = "4 months")
    ) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.title.x =element_blank(),
    ) +
    ylab(y_axis_label)
  
}


# Median lead time

make_plots(filepath = data_filepath[1],
           y_axis_label = label[1]) + 
  scale_y_continuous(breaks = seq(0, 
                                  12, 
                                  by = 1),
                     limits = c(0, 9)
  )

# Average number of appointments per patient

make_plots(filepath = data_filepath[2],
           y_axis_label = label[2]) + 
  scale_y_continuous(breaks = seq(0, 
                                  1, 
                                  by = 0.1),
                     limits = c(0, 1)
  )

# Proportion of same day appointments

make_plots(filepath = data_filepath[3],
           y_axis_label = label[3]) + 
  scale_y_continuous(breaks = seq(0, 
                                  1, 
                                  by = 0.1),
                     limits = c(0, 1)
  )

# Proportion of appointments within 2 days

make_plots(filepath = data_filepath[4],
           y_axis_label = label[4]) + 
  scale_y_continuous(breaks = seq(0, 
                                  1, 
                                  by = 0.1),
                     limits = c(0, 1)
  )

# Appointment rate (12-15 year olds)

make_plots(filepath = data_filepath[5],
           y_axis_label = label[5]) + 
  scale_y_continuous(breaks = seq(0, 
                                  0.3, 
                                  by = 0.05),
                     limits = c(0, 0.2)
  )

# Appointment rate (5-12 year olds)

make_plots(filepath = data_filepath[6],
           y_axis_label = label[6]) + 
  scale_y_continuous(breaks = seq(0, 
                                  1, 
                                  by = 0.05),
                     limits = c(0, 0.2)
  ) 