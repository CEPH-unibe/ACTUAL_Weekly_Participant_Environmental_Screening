################################################################################
### Actigraph variables relocaiton
################################################################################

# the purpose of this file

# In this document, I load all the individual actigraph measurement files (like
# steps, temperature, and the heart rate variables) and copy files into the 
# individual folders of the participants under data-raw

# clear environements
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

# loop over all participants
for(uid in uids){
  
  print(uid)
  uidx = uid
  
  # load Heart Rate, Cardiac Rythym, Heart Rate Var and Interbeatinterval from HR folder
  hr_files = list.files("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/")
  hr_files <- hr_files[grepl(paste0(uid, "_week1"), hr_files)]
  
  # grepl the individual files for every variable and participant
  filename_HR <- hr_files[grepl("HeartRate.csv", hr_files)]
  filename_CR <- hr_files[grepl("Cardiac", hr_files)]
  filename_HRV <- hr_files[grepl("HeartRateV", hr_files)]
  filename_IBI <- hr_files[grepl("Inter", hr_files)]
  
  # copy the files if they exist into the new location
  #HR
  if(length(filename_HR) != 0){
    HR <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/", filename_HR)) |> mutate(uid = uidx)
    write_csv(HR, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_HR_RAW.csv"))
  } 
  # CR
  if(length(filename_CR) != 0){  
    CR <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/", filename_CR)) |> mutate(uid = uidx)
    write_csv(CR, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_CR_RAW.csv"))
  }
  # HRV
  if(length(filename_HRV) != 0){
    HRV <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/", filename_HRV)) |> mutate(uid = uidx)
    write_csv(HRV, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_HRV_RAW.csv"))
  }
  # IBI
  if(length(filename_IBI) != 0){
    IBI <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/", filename_IBI)) |> mutate(uid = uidx)
    write_csv(IBI, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_IBI_RAW.csv"))
  }

  # Temperature
  temp_files = list.files("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/")
  temp_files <- temp_files[grepl("week1.*Temp", temp_files)]
  
  # load temperature from csv folder if the file exists
  filename_Temp <- temp_files[grepl(paste0(uid, ".*week1"), temp_files)][1]
  
  # create timeseries of temperature file from the metadata above the numeric data
  if(!is.na(filename_Temp)){
    Temp <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/", filename_Temp), skip = 9)
    
    # contruct datetime series for TEMP
    date_TEMP <- colnames(read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/", filename_Temp), skip = 3))
    time_TEMP <- colnames(read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/", filename_Temp), skip = 2))
    
    # extract time and date
    time_str <- sub("Start Time ", "", time_TEMP)
    date_str <- sub("Start Date ", "", date_TEMP)
    start_datetime <- as.POSIXct(paste(date_str, time_str), format="%d/%m/%Y %H:%M:%S")
    
    # create minute sequence
    Temp$datetime = seq(from = start_datetime, by = "60 sec", length.out = nrow(Temp))
    
    # assign uid
    Temp <- Temp |> mutate(uid = uidx)
    
    # copy new temperature file
    write_csv(Temp, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_Temp_RAW.csv"))
  }
  
  # step counts file
  step_files <- list.files("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/steps/")
  
  # load the steps file from the steps folder
  filename_Steps <- step_files[grepl(paste0(uid, ".*week1"), step_files)]
  
  if(length(filename_Steps) != 0){
    
    STEPS <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/steps/", filename_Steps), skip = 10)  |> mutate(uid = uidx)
    
    write_csv(STEPS, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_Steps_RAW.csv"))
  }
  
gc()

}




