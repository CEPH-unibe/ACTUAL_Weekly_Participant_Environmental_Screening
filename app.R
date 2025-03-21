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

  
# function to find the common prefix of file paths
common_prefix <- function(strings) {
  prefix <- strings[1]
  for (str in strings[-1]) {
    while (!startsWith(str, prefix)) {
      prefix <- substr(prefix, 1, nchar(prefix) - 1)
    }
  }
  return(prefix)
}


# load user interface and server
ui     <- source("ui.R")
server <- source("server.R")


# run the app
shinyApp(ui = ui, server = server)





# THE PLAN FOR THE APP

# UI
# you can first select the week through an interactive calendar
# and you can select if you want plots of the data (cut to the start and end time)

# in redcap: the field workers record the "Participant Visit Log"
# the start variable "pvl_start" indicates the end of an observation period
# -> we need the minimum pvl_end as a start cut of the data
# the end variable "pvl_end" indicates the start of an observation period
# -> we need the maximum pvl_start as an end time

# the redcap_event name indicated in which week the participant observed
# study_visit_week_1_arm_1



# server 
# from the selected time period you get a list of the persons that were observed
# and how many (specific) files were in their folder for this week 
# perfect would be a drop down menu of the files so that you can read the files

# plot the data of all (relevant) files


# NOTE
# save maybe the meta data of each file for plotting
# keep some info about the device used for the data

