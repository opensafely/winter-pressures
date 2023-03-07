#######################################################################
# create plots of season comparison data
#######################################################################

# SRO data
create_seasonal_sro_plots <- function(sro_measure_name){
  
  # read in the data
  season_data <- read_csv(file = here("output", 
                                      "metrics", 
                                      paste0(
                                        "season_data_",
                                        sro_measure_name,
                                        ".csv")
  ),
  col_types = cols(
    practice = col_double(),
    season = col_double(),
    value = col_double(),
    year = col_double()
  ))
  
  # set output directory
  output_directory <- fs::dir_create(
    path = here("output", 
                "metrics", 
                sro_measure_name),
    recurse = TRUE
  )
  
  seasonal_measure_outputs(
    output_directory = output_directory,
    season_data = season_data)
  
}

# kids appointment data
create_seasonal_kids_plots <- function(kids_appt_measure_name){
  
  # read in the data
  season_data <- read_csv(file = here("output", 
                                      "metrics", 
                                      paste0(
                                        "season_data_",
                                        kids_appt_measure_name,
                                        ".csv")
  ),
  col_types = cols(
    practice = col_double(),
    season = col_double(),
    value = col_double(),
    year = col_double()
  ))
  
  # set output directory
  output_directory <- fs::dir_create(
    path = here("output", 
                "metrics", 
                kids_appt_measure_name),
    recurse = TRUE
  )
  
  seasonal_measure_outputs(
    output_directory = output_directory,
    season_data = season_data)
  
}


# appointment data
create_seasonal_appointment_plots <- function(appointment_measure_name){
  
  # read in the data
  season_data <- read_csv(file = here("output", 
                                      "appointments", 
                                      paste0(
                                        "measure_seasonal_",
                                        appointment_measure_name,
                                        ".csv")
  ),
  col_types = cols(
    practice = col_double(),
    season = col_double(),
    value = col_double(),
    year = col_double()
  ))
  
  # set output directory
  output_directory <- fs::dir_create(
    path = here("output", 
                "appointments", 
                appointment_measure_name),
    recurse = TRUE
  )
  
  seasonal_measure_outputs(
    output_directory = output_directory,
    season_data = season_data)
  
}

#######################################################################
# create outputs from practice level data
#######################################################################

seasonal_measure_outputs <- function(output_directory,
                                     season_data) {

  practices_to_remove <- read_csv(file = here("output", 
                       "metrics", 
                       "practices_to_remove.csv"
  ),
  col_types = cols(
    practice = col_double()
  )
  )
  
  practices_to_remove <- pull(practices_to_remove,
                              practice)
  
  # reformat the data and calculate per practice measures
  practice_measure_data  <- calculate_seasonal_measures(
    season_data = season_data,
    practices_to_remove = practices_to_remove
  )

  # create seasonal difference and seasonal ratio histogram and plot data
  plots <- generate_plots_and_data(
    practice_measure_data = practice_measure_data
  )
  
  # save raw practice level data
  write.csv(practice_measure_data,
    file = paste(output_directory,
      "summer_winter_all_metrics.csv",
      sep = "/"
    )
  )

  # save plots and data
  save_plots_and_data(
    output_directory = output_directory,
    plot_list = plots
  )

}

#######################################################################
# calculate the seasonal measure
#######################################################################

calculate_seasonal_measures <- function(season_data,
                                        practices_to_remove){
  
  wide_season_data <- generate_wide_season_data(
    season_data = season_data,
    practices_to_remove = practices_to_remove
  )
  
  # calculate seasonal difference and seasonal rate ratio
  practice_measure_data <- calculate_season_difference(
    wide_season_data = wide_season_data)
  
  practice_measure_data <- calculate_season_ratio(
    wide_season_data = practice_measure_data)
  
  practice_measure_data
  
}

#######################################################################
# Remove necessary practices from season data
#######################################################################

remove_practices_from_season_data <- function(season_data,
                                                practices_to_remove){
  
  filter(season_data,
         !(practice %in% practices_to_remove))
  
}

#######################################################################
# widen season data
#######################################################################

# Widen the data so that seasons are column headings, and proportions are the 
#  column values.
# Remove all rows that have NA values; this ensures a practice has both a summer 
#  and winter value. 
generate_wide_season_data <- function(season_data,
                                      practices_to_remove){

  # remove necessary practices from season data
  season_data <- remove_practices_from_season_data(
    season_data = season_data,
    practices_to_remove = practices_to_remove
  )
  
  if(isFALSE(all(season_data$season %in% c(0,1)))){
    stop("Invalid season entry: values must be either 0 or 1.",
         call. = FALSE)
  }
  
  # remove duplicate rows from the input data
  season_data <- distinct(season_data)
  
  # create wider data with summer and winter as columns
  wide_season_data <- pivot_wider(season_data,
                                  names_from = season,
                                  values_from = value)
  wide_season_data <- rename(wide_season_data,
                             summer = `0`,
                             winter = `1`)
  
  wide_season_data <- drop_na(wide_season_data)
  
  wide_season_data
}


#######################################################################
# calculate per practice measures
#######################################################################

calculate_season_difference <- function(wide_season_data){
  mutate(wide_season_data,
         seasonal_difference = 100*(winter - summer)/summer
         )
}

calculate_season_ratio <- function(wide_season_data){
  mutate(wide_season_data,
         seasonal_log2_ratio = log2(winter/summer)
         )
}


#######################################################################
# plots and plot data
#######################################################################

generate_plots_and_data <- function(practice_measure_data){
  
  # create the seasonal difference histogram plot
  difference_plot <- ggplot(practice_measure_data) + 
    geom_histogram(aes(x=seasonal_difference), 
                   bins = 50) +
    theme_bw()
  
  # get the data used to create the histogram and select columns of interest
  difference_plot_data <- ggplot_build(difference_plot)$data[[1]]
  
  # Sometimes dummy data results in an empty dataframe -
  # this check for this so that the action will run locally
  # (and in GitHub actions)
  if (nrow(difference_plot_data) > 0) {
    difference_plot_data <- select(
      difference_plot_data,
      y,
      count,
      x,
      xmin,
      xmax,
      density
    )
  }
  
  # create the seasonal ratio histogram plot
  ratio_plot <- ggplot(practice_measure_data) + 
    geom_histogram(aes(x=seasonal_log2_ratio), 
                   bins = 50) +
    theme_bw()
  
  # get the data used to create the histogram and select columns of interest
  ratio_plot_data <- ggplot_build(ratio_plot)$data[[1]]

  # Sometimes dummy data results in an empty dataframe -
  # this check for this so that the action will run locally
  # (and in GitHub actions)
  if (nrow(ratio_plot_data) > 0) {
    ratio_plot_data <- select(
      ratio_plot_data,
      y,
      count,
      x,
      xmin,
      xmax,
      density
    )
  }
  
  list(difference_plot = difference_plot,
       ratio_plot = ratio_plot,
       difference_plot_data = difference_plot_data,
       ratio_plot_data = ratio_plot_data)
  
}

#######################################################################
# save plots and plot data
#######################################################################

save_plots_and_data <- function(output_directory,
                                plot_list){
  
  ggsave(plot_list$difference_plot,
         filename = "summer_winter_difference_histogram.png",
         device = "png",
         path = output_directory)
  
  write.csv(plot_list$difference_plot_data,
            file = paste(output_directory,
                         "summer_winter_difference_histogram_data.csv",
                         sep = "/"))
  
  ggsave(plot_list$ratio_plot,
         filename = "summer_winter_ratio_histogram.png",
         device = "png",
         path = output_directory)
  
  write.csv(plot_list$ratio_plot_data,
            file = paste(output_directory,
                         "summer_winter_ratio_histogram_data.csv",
                         sep = "/"))
}