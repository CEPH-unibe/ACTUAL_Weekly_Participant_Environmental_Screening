

rm(list=ls())
source("MACorWIN.R")

# libraries
library(readr);library(tidyr);library(dplyr);library(readxl);library(zoo);library(naniar);library(reshape2)
library(lubridate);library(stringr);library(ggplot2);library(gridExtra); library(grid); library(visdat);library(shiny)

# data
if(MACorWIN == 0){
    data_clean = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/week_1/week1_hourly_data_clean.csv")
    data_unclean = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Participants/week1_hourly_data_unclean.csv") |>
        mutate(uid_time = id_time) |>
        select(-id_time)
} else {
    data_clean = read_csv("Y:/CCH/Actual_Project/data/Participants/week_1/week1_hourly_data_clean.csv") 
    data_unclean = read_csv("Y:/CCH/Actual_Project/data-raw/Participants/week1_hourly_data_unclean.csv") 
}

data_clean_unclean <- data_clean |>            # x = clean
    full_join(data_unclean, by = "uid_time")   # y = unclean


source("./app_cleaned_data/server_clean_data.R")
source("./app_cleaned_data/ui_clean_data.R")


# Run the application 
shinyApp(ui = ui, server = server)
