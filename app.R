################################################################################
### WEEKLY SCREENING OF INDIVIDUAL LEVEL DATA
################################################################################


# clear environment
rm(list=ls())


# libraries
library(shiny);library(readr);library(tidyr);library(dplyr);library(readxl);library(lubridate)


# load recap data locally
redcap = read.csv("../data/redcap_data.csv") |>
  group_by(uid) |>
  summmarise(pvl_start)


data <- redcap |>
  group_by(uid) |>
  summarize(pvl_start = min(pvl_end, na.rm = TRUE))

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
# the end variable "pvl_end" indicates the start of an observation period

# the redcap_event name indicated in which week the participant observed
# study_visit_week_1_arm_1



# server 
# from the selected time period you get a list of the persons that were observed
# and how many (specific) files were in their folder for this week (problem == which week)
# perfect would be a drop down menu of the files so that you can read the files

# plot the data of all (relevant) files


# NOTE
# save maybe the meta data of each file for plotting
# keep some info about the device used for the data


# figure out the pathing system to synology drive
library(dplyr);library(readxl);library(lubridate)

campus_id <- "ts24n298"
filepath = paste0("/User/", campus_id, "SynologyDive/Participants/ACT001D/week1/ACT001D_IBH01_HUM_WK1.xlsx")

filepath <- "~/SynologyDrive/Participants/ACT001D/week1/ACT001D_IBH01_HUM_WK1.xlsx"

person <- read_excel(filepath, skip = 24) |> 
  mutate(datetime = ymd_hms(paste(Date, Time)))