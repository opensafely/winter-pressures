library(here)

source(here("analysis", "design.R"))

# add study dates in format for python
study_dates_python <- list(winter_dates = list(
    wintermonths <- format(seq(as.Date(study_dates$winter_dates$start_date), as.Date(study_dates$winter_dates$end_date), by = "month"), "%Y-%m")
), summer_dates = list(
    summermonths <- format(seq(as.Date(study_dates$summer_dates$start_date), as.Date(study_dates$summer_dates$end_date), by = "month"), "%Y-%m")
))
# write to json so that python scripts can easily pick up
jsonlite::write_json(study_dates_python, path = here("lib", "design", "study_dates.json"), auto_unbox = TRUE, pretty = TRUE)