### In this document, I load all the individual actigraph measurement files
# aggregate them, merge them together, and then merge them with the validation csv file
# from the GGIR routine.




rm(list = ls())
library(dplyr); library(ggplot2);library(ggnewscale);library(viridis);library(lubridate);library(readr)

# for handling file paths and different operating systems
source("MACorWIN.R")

# specify the week to compile (needs to match naming convention on synology)
week_indicator = "week_1"

# load redcap from CCH
if(MACorWIN == 0){
  # REDCap for uids and start and end times
  redcap = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_data.csv") |>
    dplyr::mutate(starttime = ymd_hms(starttime),
                  endtime   = ymd_hms(endtime),
                  redcap_event_name = substr(redcap_event_name, 13,18)) |>
    filter(redcap_event_name == week_indicator)|>
    filter(!(uid %in% c("ACT029U", "ACT034X", "ACT045O")))
  
} else {
  # REDCap for uids and start and end times
  redcap = read_csv("Y:/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_all.csv")|>
    dplyr::mutate(starttime = ymd_hms(starttime),
                  endtime   = ymd_hms(endtime),
                  redcap_event_name = substr(redcap_event_name, 13,18)) |>
    filter(redcap_event_name == week_indicator)|>
    filter(!(uid %in% c("ACT029U", "ACT034X", "ACT045O")))
}


# vector of all uids
uids <- unique(redcap$uid)



df_all = data.frame()



