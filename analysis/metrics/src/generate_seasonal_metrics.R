#######################################################################
# create plots of season comparison data
#######################################################################

create_seasonal_sro_plots <- function(sro_measure_name){
  
  # read in the data
  season_data <- read_csv(file = here("output", 
                                      "metrics", 
                                      sro_measure_name,
                                      "season_data.csv"),
                          col_types = cols(
                            practice = col_double(),
                            season = col_double(),
                            value = col_double(),
                            year = col_double()
                          ))
  
  # reformat the data and calculate per practice measures
  practice_measure_data  <- calculate_seasonal_measures(
    season_data = season_data
  )
  
  # create seasonal difference and seasonal ratio histogram and plot data
  plots <- generate_plots_and_data(
    practice_measure_data = practice_measure_data
  )
  
  # save plots and data
  
  output_directory <- here("output", 
                           "metrics", 
                           sro_measure_name)
  
  ggsave(plots$difference_plot,
         filename = "summer_winter_difference_histogram.png",
         path = output_directory)
  
  write.csv(plots$difference_plot_data,
            file = paste(output_directory,
                         "summer_winter_difference_histogram_data.csv",
                         sep = "/"))
  
  ggsave(plots$ratio_plot,
         filename = "summer_winter_ratio_histogram.png",
         path = output_directory)
  
  write.csv(plots$ratio_plot_data,
            file = paste(output_directory,
                         "summer_winter_ratio_histogram_data.csv",
                         sep = "/"))
  
}

#######################################################################
# calculate the seasonal measure
#######################################################################

calculate_seasonal_measures <- function(season_data){
  
  wide_season_data <- generate_wide_season_data(season_data = season_data)
  
  # calculate seasonal difference and seasonal rate ratio
  practice_measure_data <- calculate_season_difference(
    wide_season_data = wide_season_data)
  
  practice_measure_data <- calculate_season_ratio(
    wide_season_data = practice_measure_data)
  
  practice_measure_data
  
}


#######################################################################
# widen season data
#######################################################################

# Widen the data so that seasons are column headings, and proportions are the 
#  column values.
# Remove all rows that have NA values; this ensures a practice has both a summer 
#  and winter value. 
generate_wide_season_data <- function(season_data){
  
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
         seasonal_difference = winter - summer)
}

calculate_season_ratio <- function(wide_season_data){
  mutate(wide_season_data,
         seasonal_log2_ratio = log2(winter/summer))
}


#######################################################################
# plots and plot data
#######################################################################

generate_plots_and_data <- function(practice_measure_data){
  
  # create the seasonal difference histogram plot
  difference_plot <- ggplot(practice_measure_data) + 
    geom_histogram(aes(x=seasonal_difference), 
                   binwidth = 0.05) +
    theme_bw()
  
  # get the data used to create the histogram and select columns of interest
  difference_plot_data <- ggplot_build(difference_plot)$data[[1]]
  difference_plot_data <- select(difference_plot_data, 
                                 y, 
                                 count, 
                                 x, 
                                 xmin, 
                                 xmax, 
                                 density)
  
  
  # create the seasonal ratio histogram plot
  ratio_plot <- ggplot(practice_measure_data) + 
    geom_histogram(aes(x=seasonal_log2_ratio), 
                   binwidth = 0.05) +
    theme_bw()
  
  # get the data used to create the histogram and select columns of interest
  ratio_plot_data <- ggplot_build(ratio_plot)$data[[1]]
  ratio_plot_data <- select(ratio_plot_data, 
                            y, 
                            count, 
                            x, 
                            xmin, 
                            xmax, 
                            density)
  
  list(difference_plot = difference_plot,
       ratio_plot = ratio_plot,
       difference_plot_data = difference_plot_data,
       ratio_plot_data = ratio_plot_data)
  
}