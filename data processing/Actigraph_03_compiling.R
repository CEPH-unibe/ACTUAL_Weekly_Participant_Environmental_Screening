### In this document, I load all the individual actigraph measurement files
# copy files into the individual folders of the participants under data-raw




rm(list = ls())
library(dplyr); library(ggplot2);library(ggnewscale);library(viridis);library(lubridate);library(readr)


# specify the week to compile (needs to match naming convention on synology)
week_indicator = "week_1"

# load redcap from CCH
  # REDCap for uids and start and end times
  redcap = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_data.csv") |>
    dplyr::mutate(starttime = ymd_hms(starttime),
                  endtime   = ymd_hms(endtime),
                  redcap_event_name = substr(redcap_event_name, 13,18)) |>
    filter(redcap_event_name == week_indicator)|>
    filter(!(uid %in% c("ACT029U", "ACT034X", "ACT045O")))


# vector of all uids
uids <- unique(redcap$uid)



df_all = data.frame()

hr_files = list.files("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/")
temp_files = list.files("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/")
temp_files <- temp_files[grepl("Temp", temp_files)]
step_files <- list.files("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/steps/")



for(uid in uids){
  
  print(uid)
  
  # load Heart Rate, Cardiac Rythym, Heart Rate Var and Interbeatinterval from HR folder
  
  hr_files <- hr_files[grepl(paste0(uid, "_week1"), hr_files)]
  
  if(length(hr_files) != 0){
    filename_HR <- hr_files[grepl("HeartRate.csv", hr_files)]
    filename_CR <- hr_files[grepl("Cardiac", hr_files)]
    filename_HRV <- hr_files[grepl("HeartRateV", hr_files)]
    filename_IBI <- hr_files[grepl("Inter", hr_files)]
    
    HR <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/", filename_HR))
    
    CR <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/", filename_CR))
    
    HRV <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/", filename_HRV))
    
    IBI <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR/", filename_IBI))
    
    write_csv(HR, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_HR_RAW.csv"))
    write_csv(CR, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_CR_RAW.csv"))
    write_csv(HRV, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_HRV_RAW.csv"))
    write_csv(IBI, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_IBI_RAW.csv"))
  }

  
  
  # load temperature from csv folder if the file exists
  filename_Temp <- temp_files[grepl(paste0(uid, ".*week1"), temp_files)][1]
  
  
  if(!is.na(filename_Temp)){
    Temp <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/", filename_Temp), skip = 9)
    
    # contruct datetime series for TEMP
    date_TEMP <- colnames(read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/", filename_Temp), skip = 3))
    time_TEMP <- colnames(read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/", filename_Temp), skip = 2))
    
    
    time_str <- sub("Start Time ", "", time_TEMP)
    date_str <- sub("Start Date ", "", date_TEMP)
    
    start_datetime <- as.POSIXct(paste(date_str, time_str), format="%d/%m/%Y %H:%M:%S")
    
    Temp$datetime = seq(from = start_datetime, by = "60 sec", length.out = nrow(Temp))
    
    write_csv(Temp, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_Temp_RAW.csv"))
  }
  
  
  
  # load the steps file from the steps folder
  filename_Steps <- step_files[grepl(paste0(uid, ".*week1"), step_files)]
  
  if(length(filename_Steps) != 0){
    
    STEPS <- read_csv(paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/steps/", filename_Steps), skip = 10)
    
    write_csv(STEPS, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", uid, "_week1_actigraph_Steps_RAW.csv"))
  }
}




