library("tidyverse")
library("yaml")
library("here")
library("glue")
# library("rlang")

source(here("analysis", "design.R"))

# create action functions ----

## create comment function ----
comment <- function(...) {
  list_comments <- list(...)
  comments <- map(list_comments, ~ paste0("## ", ., " ##"))
  comments
}


## create function to convert comment "actions" in a yaml string into proper comments
convert_comment_actions <- function(yaml.txt) {
  yaml.txt %>%
    str_replace_all("\\\n(\\s*)\\'\\'\\:(\\s*)\\'", "\n\\1") %>%
    # str_replace_all("\\\n(\\s*)\\'", "\n\\1") %>%
    str_replace_all("([^\\'])\\\n(\\s*)\\#\\#", "\\1\n\n\\2\\#\\#") %>%
    str_replace_all("\\#\\#\\'\\\n", "\n")
}


## generic action function ----
action <- function(name,
                   run,
                   config = NULL,
                   arguments = NULL,
                   needs = NULL,
                   highly_sensitive = NULL,
                   moderately_sensitive = NULL,
                   show_outer_percentiles = NULL,
                   ... # other arguments / options for special action types
) {
  outputs <- list(
    highly_sensitive = highly_sensitive,
    moderately_sensitive = moderately_sensitive
  )
  outputs[sapply(outputs, is.null)] <- NULL
  

  action <- list(
    run = paste(c(run, arguments), collapse = " "),
    config = config,
    needs = needs,
    outputs = outputs,
   
    ... = ...
  )
  action[sapply(action, is.null)] <- NULL

  action_list <- list(name = action)
  names(action_list) <- name

  action_list
}

namelesslst <- function(...) {
  unname(lst(...))
}

## create a list of actions
lapply_actions <- function(X, FUN) {
  unlist(
    lapply(
      X,
      FUN
    ),
    recursive = FALSE
  )
}


metrics_extract_action <- function(season, cohort,date_range,output) {
  action(
  name = glue("metrics_generate_{cohort}_dataset_{season}"),
  run = glue(
    "cohortextractor:latest generate_cohort",
    " --study-definition study_definition_{cohort}",
    " --param start_date='{date_range[1]}' --param end_date='{date_range[2]}'",
    " --output-dir=output/metrics",
    " --output-format=feather",
    " --output-file output/metrics/input_{cohort}_{date_range[1]}.feather"
  ),
  highly_sensitive = lst(
    extract = glue("output/metrics/input_{cohort}_{date_range[1]}.feather")
  ),
  )
}

metrics_measures_action <- function(cohort,date_range,output){
  action(
    name = glue("metrics_generate_{cohort}_measures"),
    run = glue("cohortextractor:latest generate_measures",
               " --param start_date='{date_range[1]}' --param end_date='{date_range[2]}'",
               " --study-definition study_definition_{cohort}",
               " --output-dir=output/metrics",
    ),
    needs = namelesslst(glue("metrics_generate_{cohort}_dataset_summer"),glue("metrics_generate_{cohort}_dataset_winter")),
    moderately_sensitive = lst(
      measure_csv = glue("output/metrics/{output}.csv")
    ),
  )


}

# specify project ----

## defaults ----
defaults_list <- lst(
  version = "3.0",
  expectations = lst(population_size = 100000L)
)

## actions ----
actions_list <- splice(
  comment(
    "# # # # # # # # # # # # # # # # # # #",
    "Metrics data",
    "# # # # # # # # # # # # # # # # # # #"
  ),
  metrics_extract_action("winter","sro",study_dates$winter_dates,"input_*"),
  metrics_extract_action("summer","sro",study_dates$summer_dates,"input*"),
  metrics_extract_action("winter","kids",study_dates$winter_dates,"inpu*"),
  metrics_extract_action("summer","kids",study_dates$summer_dates,"inp*"),
  metrics_extract_action("winter","endpopulation",study_dates$winter_dates,"in_*"),
  metrics_extract_action("summer","endpopulation",study_dates$summer_dates,"i*"),
  metrics_measures_action("sro",study_dates$summer_dates,"mea*"),
  metrics_measures_action("kids",study_dates$summer_dates,"me*"),
  metrics_measures_action("endpopulation",study_dates$summer_dates,"m*"),
  
     comment("#### End ####")
)


project_list <- splice(
  list(actions = actions_list)
)

## convert list to yaml, reformat comments and whitespace ----
thisproject <- as.yaml(project_list, indent = 2) %>%
  # convert comment actions to comments
  convert_comment_actions() %>%
  # add one blank line before level 1 and level 2 keys
  str_replace_all("\\\n(\\w)", "\n\n\\1") %>%
  str_replace_all("\\\n\\s\\s(\\w)", "\n\n  \\1") %>%
  str_replace_all("\\|-\n      ","") %>%
  str_replace_all("'true'","true")


# if running via opensafely, check that the project on disk is the same as the project created here:
if (Sys.getenv("OPENSAFELY_BACKEND") %in% c("expectations", "tpp")) {
  thisprojectsplit <- str_split(thisproject, "\n")
  currentproject <- readLines(here("project.yaml"))

  stopifnot("project.yaml is not up-to-date with create-project.R.  Run create-project.R before running further actions." = identical(thisprojectsplit, currentproject))

  # if running manually, output new project as normal
} else if (Sys.getenv("OPENSAFELY_BACKEND") %in% c("")) {

  ## output to file ----
  writeLines(thisproject, here("epi_additions.yaml"))
  # yaml::write_yaml(project_list, file =here("project.yaml"))

  ## grab all action names and send to a txt file

  names(actions_list) %>%
    tibble(action = .) %>%
    mutate(
      model = action == "" & lag(action != "", 1, TRUE),
      model_number = cumsum(model),
    ) %>%
    group_by(model_number) %>%
    summarise(
      sets = str_trim(paste(action, collapse = " "))
    ) %>%
    pull(sets) %>%
    paste(collapse = "\n") %>%
    writeLines(here("actions.txt"))

  # fail if backend not recognised
} else {
  stop("Backend not recognised by create.project.R script")
}
