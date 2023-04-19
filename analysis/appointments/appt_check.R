library(dplyr)
library(readr)
library(magrittr)
library(glue)
library(stringr)
library(here)
library(tidyr)

source(here("analysis", "utils.R"))

listsize_file = here("output", "listsize", "measure_listsize.csv")

listsizes = read_csv(listsize_file,
                     col_types = cols_only(
                       practice = col_integer(),
                       population = col_double(),
                       date = col_date()
                     )
)

target_dir = here("output", "appointments")
target_pattern = "measure_monthly_.*.csv"

listsize_directory = here("output", "listsize")

target_files = list.files(
  path = target_dir,
  pattern = target_pattern,
  full.names = TRUE,
  recursive = TRUE
)  %>%
  str_subset(., "overall", negate = TRUE) %>%
  str_subset(., "normalised", negate = TRUE)


output_dir = target_dir

### Creating a directory to record which practices are not present
### in either the raw counts or the population data
check_directory <- fs::dir_create(
  path = here("output", "check")
)

f_count = 0
# create a df with listsize =1 if a listsize exists for a practice on a date 
df <- listsizes %>%
  select(date,practice) %>%
  mutate(listsize = 1)

## for each monthly measure full join to df and add a coulumn with 1 if a practice exists on a date
## and NA if it doesn't exist
for (f in target_files) {
  f_count = f_count + 1
  f_name <- basename(f) %>%
    str_replace("measure_monthly_","") %>%
    str_replace(".csv","")
  
  d <- read_csv(f,
               col_types = cols_only(
                 practice = col_integer(),
                 value = col_integer(),
                 date = col_date()
               )
  ) %>% 
    select(date,practice) %>%
    mutate(!!as.name(f_name) :=1)
  
  df <- df %>%
    full_join(d, by = c("date", "practice"))
}

## create a dataset of practices that exist for list size and all monthly measures
df_non_missing<- df %>%
  drop_na()

write.csv(df_non_missing, file = here("output", "check","no_dropped_practice.csv"), row.names = FALSE, quote = FALSE)

## summarise dataset of practices that exist for list size and all monthly measures
df_non_missing_summary<-df_non_missing %>%
  group_by(date) %>%
  summarise(num_practices_with_all = n()) 

write.csv(df_non_missing_summary, file = here("output", "check","no_dropped_practice_summary.csv"), row.names = FALSE, quote = FALSE)

## create a dataset of practices that doesn't exist for any of list size or any monthly measures
df_missing_any <- df %>% 
  anti_join(df_non_missing,by=c("practice","date"))

write.csv(df_missing_any, file = here("output", "check","dropped_any_practice.csv"), row.names = FALSE, quote = FALSE)

## summarise dataset of practices that doesn't exist for any of list size or any monthly measures
df_missing_any_summary <- df_missing_any %>% 
  group_by(date) %>%
  summarise(num_practices_missing_any = n()) 

write.csv(df_missing_any_summary, file = here("output", "check","dropped_any_practice_summary.csv"), row.names = FALSE, quote = FALSE)

## summarise percentage of missing practices for each month 
df_summary <- df_non_missing_summary %>%
  full_join(df_missing_any_summary,by="date") %>%
  mutate(percentage_missing_any = round(num_practices_missing_any / (num_practices_missing_any + num_practices_with_all)*100,2))

write.csv(df_summary, file = here("output", "check","dropped_practice_summary.csv"), row.names = FALSE, quote = FALSE)


