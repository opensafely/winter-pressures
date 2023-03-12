## Import libraries ----
library('tidyverse')
library('lubridate')
library('arrow')
library('here')
library('glue')

source(here("analysis", "design.R"))

### Create a directory for output plots
fs::dir_create(
  path = here("output", "epi","plots")
)


irr_data <- read_csv(here("output", "epi", "irr_data.csv"))

irr_plot_data_func<- function(met,outc){
  irr_data %>%
    filter(metric == met,outcome == outc) 
}

irr_args <- expand.grid(met = metrics,outc =outcomes) 

irr_plots<- irr_args %>% 
  mutate(
    data_plot = map2(
      .x = as.character(met),
      .y = as.character(outc),
      .f = irr_plot_data_func)
      )
    
for (i in 1:nrow(irr_plots)){
  bag <- irr_plots$data_plot[[i]] %>%
   ggplot() +
    geom_pointrange( mapping=aes(x=decile, y=irr, ymin=irr.ll, ymax=irr.ul), size=1, color="darkslateblue", fill="white") +
    scale_x_continuous(breaks=seq(1:10)) +
    ylab("Log Incidence Rate Ratio") +
    ggtitle(glue("{irr_plots$data_plot[[i]]$outcome[1]} IRR for {irr_plots$data_plot[[i]]$metric[1]} decile")) +
    theme_bw() +
    coord_flip() 
  
  bag %>%
    ggsave(
          filename = here(
            "output", "epi","plots",glue("{irr_plots$data_plot[[i]]$outcome[1]}_{irr_plots$data_plot[[i]]$metric[1]}.png")),
          width = 15, height = 20, units = "cm"
    )
}

