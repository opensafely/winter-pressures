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
    path = here(
      "output",
      "appointments",
      appointment_measure_name
    ),
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
  
  o_file = paste(output_directory,
    "summer_winter_all_metrics.csv",
    sep = "/"
  )
  # save raw practice level data
  write.csv(practice_measure_data,
    file = o_file
  )

  cat(glue("Writing {nrow(practice_measure_data)} to file {output_directory}\n"))

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
  
  practices_before_removal <- unique(season_data$practice)
  
  # remove necessary practices from season data
    ### if running locally skip the filtering by practice size / change
  if (!(Sys.getenv("OPENSAFELY_BACKEND") %in% c("", "expectations"))) {
  season_data <- remove_practices_from_season_data(
    season_data = season_data,
    practices_to_remove = practices_to_remove
  )
  }
  practices_after_removal <- unique(season_data$practice)
  
  print(paste0("Number of practices before removal: ",
               length(practices_before_removal)))
  
  print(paste0("Number of practices after removal: ",
               length(practices_after_removal)))
  
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
  
  running_remotely = !(Sys.getenv("OPENSAFELY_BACKEND") %in% c("", "expectations"))

  percentage_to_remove = 0.05
  nbins = 50

  # ########################################
  # # difference plot
  # ########################################
  
  # #remove non-finite values: Inf, NAN, NA
  # difference_data <- practice_measure_data[which(is.finite(practice_measure_data$seasonal_difference)== TRUE),]
  # # order rows by difference column
  # difference_data <- arrange(difference_data, seasonal_difference) 
  # # find number of rows to chop of top and bottom
  # number_to_remove <- ceiling(0.5 * percentage_to_remove * nrow(difference_data))
  
  # if(number_to_remove >= 1){
      
  #   #find the row index for rows to remove from top and bottom
  #   rows_to_remove_index <- c(seq(1, number_to_remove, by = 1), 
  #                             seq(nrow(difference_data) - number_to_remove + 1, nrow(difference_data), by = 1)
  #   )
  #   # find the rows to keep by index
  #   rows_to_keep_index <- which(!(1:nrow(difference_data) %in% rows_to_remove_index))
  #   # subset the data to only the rows to keep
  #   difference_data <- difference_data[rows_to_keep_index, ]
    
  # } else {
    
  #   difference_data <- difference_data
    
  # }
  
  # create the seasonal difference histogram plot
  difference_plot <- ggplot(practice_measure_data) + 
    geom_histogram(aes(x=seasonal_difference), 
                   bins = nbins) +
    theme_bw() +
    xlab("Seasonal difference") +
    ylab("Count")

  # get the data used to create the histogram and select columns of interest
  difference_plot_data <- ggplot_build(difference_plot)$data[[1]]

  difference_plot_data_redacted = data.frame()
  difference_plot_redacted = NA

  # Sometimes dummy data results in an empty dataframe -
  # this check for this so that the action will run locally
  # (and in GitHub actions)
  if ( nrow(difference_plot_data) > 0) {

    ### REDACT/ROUND HISTOGRAM DATA
    difference_plot_data_redacted <- difference_plot_data %>%
      mutate(count = redact_and_round(count))
    
    rs = formals(redact_and_round)$redaction_string

    if ( running_remotely ) {
      difference_plot_redacted = difference_plot_data_redacted %>%
        filter(count != rs) %>%
        ggplot(aes(x = x, y = y)) +
        geom_bar(stat = "identity") +
        theme_bw()  +
        xlab("Seasonal difference") +
        ylab("Count")
    } else {
      difference_plot_redacted = difference_plot
    }
    
    difference_plot_data <- select(
      difference_plot_data,
      y,
      count,
      x,
      xmin,
      xmax,
      density
    )

    difference_plot_data_redacted <- select(
      difference_plot_data_redacted,
      y,
      count,
      x,
      xmin,
      xmax,
      density
    )

  }

  ########################################
  # ratio plot
  ########################################
  
  # #remove non-finite values: Inf, NAN, NA
  # ratio_data <- practice_measure_data[which(is.finite(practice_measure_data$seasonal_log2_ratio)== TRUE),]
  # # order rows by difference column
  # ratio_data <- arrange(ratio_data, seasonal_log2_ratio) 
  # # find number of rows to chop of top and bottom
  # number_to_remove <- ceiling(0.5 * percentage_to_remove * nrow(ratio_data))
  
  # if(number_to_remove >= 1){
      
  #   #find the row index for rows to remove from top and bottom
  #   rows_to_remove_index <- c(seq(1, number_to_remove, by = 1), 
  #                             seq(nrow(ratio_data) - number_to_remove + 1, nrow(ratio_data), by = 1)
  #   )
  #   # find the rows to keep by index
  #   rows_to_keep_index <- which(!(1:nrow(ratio_data) %in% rows_to_remove_index))
  #   # subset the data to only the rows to keep
  #   ratio_data <- ratio_data[rows_to_keep_index, ]
  
  # } else {
    
  #   ratio_data <- ratio_data
    
  # }
  
  
  
  # create the seasonal ratio histogram plot
  ratio_plot <- ggplot(practice_measure_data) + 
    geom_histogram(aes(x=seasonal_log2_ratio), 
                   bins = nbins) +
    theme_bw() +
    # xlab(expression(Seasonal~log[2]~(frac(winter,summer)))
    xlab(expression(log[2]~(Seasonal~ratio))) +
    ylab("Count")
  
  # get the data used to create the histogram and select columns of interest
  ratio_plot_data <- ggplot_build(ratio_plot)$data[[1]]

  ratio_plot_data_redacted <- data.frame()
  ratio_plot_redacted <- NA

  # Sometimes dummy data results in an empty dataframe -
  # this check for this so that the action will run locally
  # (and in GitHub actions)
  if (nrow(ratio_plot_data) > 0) {

    ### REDACT/ROUND HISTOGRAM DATA
    ratio_plot_data_redacted <- ratio_plot_data %>%
      mutate(count = redact_and_round(count))
    
    rs = formals(redact_and_round)$redaction_string

    if ( running_remotely ) {
      ratio_plot_redacted = ratio_plot_data_redacted %>%
        filter(count != rs) %>%
        ggplot(aes(x = x, y = y)) +
        geom_bar(stat = "identity") +
        theme_bw() +
        xlab(expression(log[2]~(Seasonal~ratio))) +
        ylab("Count")
    } else {
      ratio_plot_redacted <- ratio_plot
    }

    ratio_plot_data <- select(
      ratio_plot_data,
      y,
      count,
      x,
      xmin,
      xmax,
      density
    )

    ratio_plot_data_redacted <- select(
      ratio_plot_data_redacted,
      y,
      count,
      x,
      xmin,
      xmax,
      density
    )
  }

  
  list(
    # raw
    difference_plot = difference_plot,
    ratio_plot = ratio_plot,
    difference_plot_data = difference_plot_data,
    ratio_plot_data = ratio_plot_data,
    # redacted
    difference_plot_redacted = difference_plot_redacted,
    ratio_plot_redacted = ratio_plot_redacted,
    difference_plot_data_redacted = difference_plot_data_redacted,
    ratio_plot_data_redacted = ratio_plot_data_redacted
    )
  
}

#######################################################################
# save plots and plot data
#######################################################################

save_plots_and_data <- function(output_directory,
                                plot_list){
  
  cat(glue("Plots and data to save to {output_directory}"))
  cat(glue(" - {plot_list}"))

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

  ### REDACTED DATA

  redacted_directory <- fs::dir_create(
    path = paste(output_directory, "redacted", sep = "/"),
    recurse = TRUE
  )
  cat( glue("writing to redacted directory: {redacted_directory}") )

  write.csv(plot_list$difference_plot_data_redacted,
    file = paste(redacted_directory,
      "summer_winter_difference_histogram_data_redacted.csv",
      sep = "/"
    )
  )

  if ( !is.na(plot_list$difference_plot_redacted) ) {
    ggsave(plot_list$difference_plot_redacted,
      filename = "summer_winter_difference_histogram_redacted.png",
      device = "png",
      path = redacted_directory
    )
  }

  write.csv(plot_list$ratio_plot_data_redacted,
    file = paste(redacted_directory,
      "summer_winter_ratio_histogram_data_redacted.csv",
      sep = "/"
    )
  )

  if ( !is.na(plot_list$ratio_plot_redacted) ) {
    ggsave(plot_list$ratio_plot_redacted,
      filename = "summer_winter_ratio_histogram_redacted.png",
      device = "png",
      path = redacted_directory
    )
  }
}