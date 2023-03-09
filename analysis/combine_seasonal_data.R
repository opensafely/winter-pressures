library(dplyr)
library(readr)
library(magrittr)
library(glue)
library(stringr)
library(here)

target_file = "summer_winter_all_metrics.csv"

practice_level_files = list.files(pattern = target_file, recursive = TRUE)
practice_level_store = data.frame()

f_count = 0

cat(glue("{length(practice_level_files)} files have been identified"))
cat(glue("- {practice_level_files}\n\n"))

for (f in practice_level_files) {
    f_count = f_count + 1
    v = dirname(f) %>%
        str_split("/") %>%
        unlist() %>%
        last()
    d = read_csv(f,
        col_types = cols_only(
            practice = col_integer(),
            year = col_integer(),
            seasonal_difference = col_double(),
            seasonal_log2_ratio = col_double()
        )
    ) %>% mutate(variable = v)

    cat(glue("[{f_count}] Reading in {v} data\n"))

    if ( nrow(practice_level_store) == 0) {
        practice_level_store = d
    } else {
        practice_level_store = practice_level_store %>% bind_rows(d)
    }

}

### Create output directory
output_directory <- fs::dir_create(
    path = here("output","combined")
)

### Write data file file
write.csv(practice_level_store,
    file = paste(output_directory,
        "combined_seasonal_data.csv",
        sep = "/"
    ), row.names=FALSE
)
