################################################################################
### GGIR compiling
################################################################################

# the purpose of this file

# In this document, I load all the chosen output from every participant (acceleration 
# and sleep, and save it in the top folder of every participant

# ! I HAVE NOT DONE SLEEP YET !

# empty environment
rm(list = ls())

# libraries
library(dplyr); library(ggplot2);library(ggnewscale);library(viridis);library(lubridate);library(readr)

# week indicator
week_indicator = "week_1"

# load redcap from CCH for uids and start and end times
redcap = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_data.csv") |>
  mutate(starttime = ymd_hms(starttime),
         endtime   = ymd_hms(endtime),
         redcap_event_name = substr(redcap_event_name, 13,18)) |>
  filter(redcap_event_name == week_indicator)|>
  filter(!(uid %in% c("ACT029U", "ACT034X", "ACT045O"))) |>
  filter(str_starts(uid, "ACT"))


# vector of all uids
uids <- unique(redcap$uid)


# empty data frames
df_validation = data.frame()


# loop through all participants
for(uid in uids){
  
  # load the validation mdat file from the participant
  location = paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/", week_indicator, "/",uid, "/Raw_processed/output_",uid,"/meta/ms5.outraw/40_100_400/") 
  
  validationCSV = list.files(location, pattern = "\\.csv$")
  if (length(validationCSV) == 0) {
    message(paste("No mdat-validation file found for", uid, "- skipping."))
    next  # skip to next iteration
  }
  
  # load and configure weartime validation dataset
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
  

  # save the raw and hourly aggregated data for every participant
  write_csv(mdat, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/", week_indicator, "/",uid, "/", uid, "_week1_actigraph_validation_RAW.csv"))

  # rbind to all participants data set
  df_validation = rbind(df_validation, mdat)
}

# save the raw rbinded data
write_csv(df_validation, "/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/", week_indicator, "/", week_indicator,  "_actigraph_validation_RAW.csv")


