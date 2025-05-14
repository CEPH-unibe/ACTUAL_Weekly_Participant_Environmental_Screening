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


# data
data_clean = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/week_1/week1_hourly_data_clean.csv")
data_unclean = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Participants/week1_hourly_data_unclean.csv") |>
        mutate(uid_time = id_time) |>
        select(-id_time)


data_clean_unclean <- data_clean |>            # x = clean
    full_join(data_unclean, by = "uid_time")   # y = unclean


source("./app_cleaned_data/server_clean_data.R")
source("./app_cleaned_data/ui_clean_data.R")


# Run the application 
shinyApp(ui = ui, server = server)
