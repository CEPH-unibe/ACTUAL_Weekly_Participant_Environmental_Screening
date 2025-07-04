################################################################################
### WEEKLY SCREENING OF INDIVIDUAL LEVEL DATA
################################################################################

# the purpose of this app

# to compare the cleaned aggregated iButton measurements with uncleaned aggregated
# iButton measurements to evaluate the effect of the cleaning


# empty Environment
rm(list=ls())

# libraries
library(readr);library(tidyr);library(dplyr);library(readxl);library(zoo);library(naniar);library(reshape2)
library(lubridate);library(stringr);library(ggplot2);library(gridExtra); library(grid); library(visdat);library(shiny)

# week indicator
week_indicator = "week_1"

# load the data 
data_clean = read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/", week_indicator, "/", week_indicator, "_IB_hourly_data_clean.csv"))
data_unclean = read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Participants/", week_indicator, "_IB_hourly_data_unclean.csv")) |>
        mutate(uid_time = id_time) |>
        select(-id_time)

# join both data sets into one
data_clean_unclean <- data_clean |>            # x = clean
    full_join(data_unclean, by = "uid_time")   # y = unclean

# server and ui
source("./app_cleaned_data/server_clean_data.R")
source("./app_cleaned_data/ui_clean_data.R")


# Run the application 
shinyApp(ui = ui, server = server)
