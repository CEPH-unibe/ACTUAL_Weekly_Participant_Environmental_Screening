### In this document, I load all the chosen output from every participant, aggregate it, 
# and then save it under /data before merging it with the other actigraph data


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


df_validation = data.frame()





# loop through all participants
for(uid in uids){
  
  
  # load the validation mdat from the participant
  location = paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/Raw_processed/output_",uid,"/meta/ms5.outraw/40_100_400/") 
  
  validationCSV = list.files(location, pattern = "\\.csv$")
  if (length(validationCSV) == 0) {
    message(paste("No RAW file found for", uid, "- skipping."))
    next  # skip to next iteration
  }
  
  mdat = read_csv(paste0(location, validationCSV))
  mdat$datetime <- as.POSIXct(mdat$timenum, origin = "1970-01-01", tz = "UTC")
  
  
  # exclude data before/after the pvl's
  start_time <- redcap$starttime[redcap$uid == uid]
  end_time <- redcap$endtime[redcap$uid == uid]
  
  mdat <- mdat |>
    filter(datetime >= start_time & datetime <= end_time)
  
  
  
  # clean mdat
  mdat <-  mdat |>
    
    # unselect duplicate and empty columns
    select(-timenum, -selfreported) |>
    
    # assign correct class
    mutate(across(c(SleepPeriodTime,sibdetection, invalidepoch, guider, window, class_id), as.factor))
  
  
  
  
  # reassign classes and create timestamp to group by
  mdat <- mdat |>
    mutate(
      sleep_IN = ifelse(class_id %in% c(0,1,2), 1, 0),
      sleep_WA = ifelse(class_id %in% c(3,4), 1, 0),
      day_IN = ifelse(class_id %in% c(5,12:14), 1, 0),
      day_LI = ifelse(class_id %in% c(6,15:17), 1, 0),
      day_MO = ifelse(class_id %in% c(7:11), 1, 0),
      
      timestamp_hour = floor_date(datetime, unit = "hour")
    )
  
  
  
  # hourly aggregation
  mdat_hour <- mdat |>
    group_by(timestamp_hour) |>
    summarize(
      validity = mean(as.numeric(invalidepoch), na.rm = TRUE) - 1,
      validity_q = quantile(as.numeric(invalidepoch), .75) - 1,
      across(c(sleep_IN, sleep_WA, day_IN, day_LI, day_MO, ACC), mean, na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(
      max_var = c("sleep_IN", "sleep_WA", "day_IN", "day_LI", "day_MO")[
        max.col(as.data.frame(across(c(sleep_IN, sleep_WA, day_IN, day_LI, day_MO))), ties.method = "first")],
      uid = uid)

  
  
  
  
  df_validation = rbind(df_validation, mdat_hour)
  
  
  
}

# save the aggregated data
if(MACorWIN == 0){

  write_csv(df_validation, "/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/week_1/week1_actigraph_validation_hourly.csv")
  
} else {
  # write the data to csv 
  write_csv(data_full, "Y:/CCH/Actual_Project/data/Participants/week_1/week1_actigraph_validation_hourly.csv")
}











