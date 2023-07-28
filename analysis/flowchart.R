library(Gmisc, quietly = TRUE)
library(glue)
library(htmlTable)
library(grid)
library(magrittr)
library(tidyverse)
library(here)

source(here("analysis", "utils.R"))

round_redact<-function(N){
  output<-tibble(N) %>% mutate(N=case_when(
    N==0 ~ as.integer(0),
    N>7  ~ as.integer(round(N/5,0)*5),
    T~-1L
))
  return(output)
}

fs::dir_create(
  path = here("output", "check")
)

appointment_all<-read_csv(here("output/appointments/measure_monthly_median_lead_time_in_days_by_booked_month.csv")) %>%
  distinct(practice) 

n_appointment_all<- appointment_all%>%
  nrow

metrics_all<-read_csv(here("output/metrics/monthly/measure_sodium_rate.csv")) %>%
  distinct(practice) 

n_metrics_all<- metrics_all %>%
  nrow

under12_all<-read_csv(here("output/metrics/monthly/measure_under12_appt_rate.csv")) %>%
  distinct(practice) 

over12_all<-read_csv(here("output/metrics/monthly/measure_over12_appt_rate.csv")) %>%
  distinct(practice) 

listsize_all <- read_csv(here("output/listsize/measure_listsize.csv")) %>%
  distinct(practice) 


all <- appointment_all %>%
  full_join(metrics_all,by="practice") %>%
  full_join(under12_all,by="practice") %>%
  full_join(over12_all,by="practice") %>%
  full_join(listsize_all,by="practice")


not_in_sql<- all %>%
anti_join(appointment_all)

n_not_in_sql <- not_in_sql %>%
  nrow

n_all<- all %>%
  nrow

n_listsize <-  listsize_all %>%
  nrow

not_in_listsize <- all %>%
  anti_join(listsize_all)
  
n_not_in_listsize <- not_in_listsize %>%
  nrow()

normalised_appointments_all <- appointment_all %>%
  inner_join(listsize_all,by="practice")

n_normalised_appointments_all <- normalised_appointments_all %>%
  nrow()

practices <- appointment_all  %>% mutate(appointment=T) %>%
  full_join(metrics_all%>% mutate(metrics=T),by="practice")%>%
  full_join(under12_all%>% mutate(under12=T),by="practice")%>%
  full_join(over12_all%>% mutate(over12=T),by="practice")%>%
  full_join(listsize_all%>% mutate(listsize=T),by="practice")

write_csv(practices,here("output/check/practice_counts.csv"))


org_cohort <- boxGrob(glue("Total Practices",
                           "n = {pop}",
                           pop = txtInt(n_all),
                           .sep = "\n"))
eligible <- boxGrob(glue("Appointment measures practices",
                         "n = {pop}",
                         pop = txtInt(n_appointment_all),
                         .sep = "\n"))

included <- boxGrob(glue("Normalised Appointment measures practices",
                         "n = {incl}",
                         incl = txtInt(n_normalised_appointments_all),
                         .sep = "\n"))

excluded_a <- boxGrob(glue("Excluded:", 
                           "Practices not in SQL Runner",
                           "n = {incl}",
                           incl = txtInt(n_not_in_sql),
                           .sep = "\n"))

excluded_b <- boxGrob(glue("Excluded:",
                           "Practices not in cohort extractor",
                           "n = {incl}",
                           incl = txtInt(n_not_in_listsize),
                           .sep = "\n"))

grid.newpage()
png(filename=here("output/check/flow.png"), height = 5, width = 8.5, units = "in",res = 330)
vert <- spreadVertical(.from = .99,
                       .to = 0.01,
                       org_cohort = org_cohort,
                       eligible = eligible,
                       included = included,
                       .type = "center")

vert$grps <- NULL

excluded <- moveBox(excluded_a,
                    x = .75,
                    y = coords(vert$eligible)$bottom + distance(vert$org_cohort, vert$included, half = TRUE, center = FALSE, type = c("vertical"))*0.8)

excluded_b <- moveBox(excluded_b,
                      x = .75,
                      y = coords(vert$included)$bottom + distance(vert$org_cohort, vert$included, half = TRUE, center = FALSE, type = c("vertical"))*0.8)


for (i in 1:(length(vert) - 1)) {
  connectGrob(vert[[i]], vert[[i + 1]], type = "vert") %>%
    print
}

connectGrob(vert$org_cohort, excluded, type = "L")
connectGrob(vert$eligible, excluded_b, type = "L")

# Print boxes
vert
excluded
excluded_b


dev.off()

#### create csv of redacted flowchart data
redacted <- round_redact(n_all) %>% mutate(practice= "Total Practices") %>%
          bind_rows(round_redact(n_appointment_all)
                    %>% mutate(practice= "Appointment measures practices")) %>%
  bind_rows(round_redact(n_normalised_appointments_all)
            %>% mutate(practice= "Normalised Appointment measures practices")) %>%
  bind_rows(round_redact(n_not_in_sql)
            %>% mutate(practice= "Practices not in SQL Runner")) %>%
  bind_rows(round_redact(n_not_in_listsize)
            %>% mutate(practice= "Practices not in cohort extractor"))

write_csv(redacted,here("output/check/redacted_flowchart_data.csv"))



org_cohort <- boxGrob(glue("{redacted$practice[1]}",
                           "n = {pop}",
                           pop = txtInt(redacted$N[1]),
                           .sep = "\n"))

eligible <- boxGrob(glue("{redacted$practice[2]}",
                         "n = {pop}",
                         pop = txtInt(redacted$N[2]),
                         .sep = "\n"))

included <- boxGrob(glue("{redacted$practice[3]}",
                         "n = {incl}",
                         incl = txtInt(redacted$N[3]),
                         .sep = "\n"))

excluded_a <- boxGrob(glue("Excluded:", 
                           "{redacted$practice[4]}",                        
                           "n = {incl}",
                           incl = txtInt(redacted$N[4]),
                           .sep = "\n"))

excluded_b <- boxGrob(glue("Excluded:",
                           "{redacted$practice[5]}",
                           "n = {incl}",
                           incl = txtInt(redacted$N[5]),
                           .sep = "\n"))

grid.newpage()
png(filename=here("output/check/flow_redacted.png"), height = 5, width = 8.5, units = "in",res = 330)
vert <- spreadVertical(.from = .99, 
                       .to = 0.01,
                       org_cohort = org_cohort,
                       eligible = eligible,
                       included = included,
                       .type = "center")
vert$grps <- NULL
excluded <- moveBox(excluded_a,
                    x = .75,
                    y = coords(vert$eligible)$bottom + distance(vert$org_cohort, vert$included, half = TRUE, center = FALSE, type = c("vertical"))*0.8)
excluded_b <- moveBox(excluded_b,
                      x = .75,
                      y = coords(vert$included)$bottom + distance(vert$org_cohort, vert$included, half = TRUE, center = FALSE, type = c("vertical"))*0.8)

for (i in 1:(length(vert) - 1)) {
  connectGrob(vert[[i]], vert[[i + 1]], type = "vert") %>%
    print
}
connectGrob(vert$org_cohort, excluded, type = "L")
connectGrob(vert$eligible, excluded_b, type = "L")
# Print boxes
vert
excluded
excluded_b

dev.off()
