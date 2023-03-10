library(dplyr)
library(tidyr)
library(readr)
library(magrittr)
library(here)

source(here("analysis", "utils.R"))

output_directory = here( "output", "combined" )
output_file = "combined_seasonal_data.csv"

combined_data = paste(
    output_directory, output_file,
    sep = "/" ) %>%
    read_csv()

summary_statistics = combined_data %>%
    pivot_longer(
        names_to = "method",
        values_to = "value",
        cols = starts_with("seasonal") ) %>%
    group_by(year, variable, method) %>%
        summarise(
            num = n(),
            num_missing = sum(is.na(value)),
            num_infinite = sum(is.na(value)),
            median = median(value, na.rm = TRUE) %>% round(digits = 1),
            p05 = quantile(value, probs = seq(0, 1, 0.05), na.rm = TRUE)["95%"] %>% round(digits = 1),
            p95 = quantile(value, probs = seq(0, 1, 0.05), na.rm = TRUE)[ "5%"] %>% round(digits = 1),
            IQR = IQR(value, na.rm = TRUE) %>% round(digits = 1),
            Q1 = quantile(value, na.rm = TRUE)["25%"] %>% round(digits = 1),
            Q3 = quantile(value, na.rm = TRUE)["75%"] %>% round(digits = 1)
        )
    
summary_statistics_nondisclosive = summary_statistics %>%
    mutate(across(starts_with("num"), redact_and_round))


### Create output directory
output_directory <- fs::dir_create(
    path = here("output","combined")
)

### Write data file file
write.csv(summary_statistics,
    file = paste(output_directory,
        "seasonal_summaries.csv",
        sep = "/"
    ),
    row.names=FALSE
)

###  Write data file file
write.csv(summary_statistics_nondisclosive,
    file = paste(output_directory,
        "seasonal_summaries_nondisclosive.csv",
        sep = "/"
    ),
    row.names = FALSE
)
