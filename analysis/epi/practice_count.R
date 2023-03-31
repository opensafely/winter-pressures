## Import libraries ----
library('tidyverse')
library('lubridate')
library('arrow')
library('here')
library('glue')
library('purrr')


deciles_n<-read_csv(here("output","combined","practice_counts_per_decile.csv")) %>%
  filter(method == "seasonal_difference") %>%
  summarise(metric = variable,
            num_practices = num_practices)

irr_data <- read_csv(here("output", "epi", "irr_data.csv"))

# check no data is removed 
irr_data_rows <- nrow(irr_data)

# add deciles
irr_data <- irr_data %>%
  inner_join(deciles_n,"metric")

print("number of rows dropped")
print(irr_data_rows - nrow(irr_data))

### Write data file file
write.csv(irr_data,
    file = paste(here("output", "epi"),
        "irr_data.csv",
        sep = "/"
    ),
    row.names=FALSE
)
