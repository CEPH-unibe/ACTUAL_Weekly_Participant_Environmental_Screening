################################################################################
### WEEKLY SCREENING OF INDIVIDUAL LEVEL DATA
################################################################################


# clear environment
rm(list=ls())


# libraries
library(shiny);library(readr);library(tidyr);library(dplyr);library(readxl)
library(lubridate);library(stringr);library(ggplot2)


# load cleaned recap data locally
redcap = read_csv("../data/redcap_data.csv") |>
  dplyr::mutate(starttime = ymd_hms(starttime),
                endtime   = ymd_hms(endtime),
                redcap_event_name = substr(redcap_event_name, 13,18))

  
# functions
source("functions.R")

# load user interface and server
ui  <- source("ui.R")
se  <- source("server.R")


# run the app
shinyApp(ui = ui, server = server)


# Notes:
# in redcap: the field workers record the "Participant Visit Log"
# the start variable "pvl_start" indicates the end of an observation period
# -> we need the minimum pvl_end as a start cut of the data
# the end variable "pvl_end" indicates the start of an observation period
# -> we need the maximum pvl_start as an end time

# the redcap_event name indicated in which week the participant observed
# study_visit_week_1_arm_1 = week1




