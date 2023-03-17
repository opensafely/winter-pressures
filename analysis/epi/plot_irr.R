## Import libraries ----
library('tidyverse')
library('lubridate')
library('arrow')
library('here')
library('glue')

source(here("analysis", "design.R"))

### Create a directory for output plots
fs::dir_create(
  path = here("output", "epi","plots","combined")
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
  plots <- irr_plots$data_plot[[i]] %>%
   ggplot() +
    geom_pointrange( mapping=aes(x=decile, y=irr, ymin=irr.ll, ymax=irr.ul), size=1, color="darkslateblue", fill="white") +
    scale_x_continuous(breaks=seq(1:10)) +
    # scale_y_log10() + 
    ylab("Incidence Rate Ratio") +
    theme_bw() +
    coord_flip() 
  
  plots %>%
    ggsave(
          filename = here(
            "output", "epi","plots",glue("{irr_plots$data_plot[[i]]$outcome[1]}_{irr_plots$data_plot[[i]]$metric[1]}.png")),
          width = 15, height = 20, units = "cm"
    )
}


# Combined outcomes plots
irr_overlay<-irr_data %>% 
  filter( outcome== "death_date" | outcome == "emergency_date" | outcome == "admitted_unplanned_date") %>%
  mutate(outcome_lab = case_when(outcome=="death_date"~"All cause mortality",
                                 outcome=="emergency_date"~"A&E attendance",
                                 outcome=="admitted_unplanned_date"~"Unplanned hospital admission"))


for (i in 1:length(metrics)){
  plot_overlay <- irr_overlay %>% 
    filter(metric==metrics[i]) %>%
    ggplot() +
    geom_hline(yintercept=1,alpha =0.3) +
    geom_pointrange( mapping=aes(x=decile, y=irr, ymin=irr.ll, ymax=irr.ul,group = outcome_lab,colour = outcome_lab,  ),position =  position_dodge2(width = 0.55),size=0.5) +
    scale_x_continuous(breaks=seq(1:10)) +
    # scale_y_log10() + 
    xlab(glue("Decile ({str_replace_all(metrics[i],'_', ' ') })")) +
    ylab("Incidence Rate Ratio") +
    theme_bw() +
    coord_flip() + 
    theme(legend.position="bottom",legend.title=element_blank())
  
  plot_overlay %>%
    ggsave(
      filename = here(
        "output", "epi","plots","combined",glue("{metrics[i]}_combined.png")),
      width = 15, height = 20, units = "cm"
    )
}

