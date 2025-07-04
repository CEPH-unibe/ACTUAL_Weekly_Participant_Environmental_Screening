################################################################################
### Actigraph compiling
################################################################################

# the purpose of this file

# in this document I load all the actigraph files from the participants individual
# folders,  clean them by the PVL and the weartime validation output from the 
# GGIR routine, rbind them and save them in the data folder without aggregating)

# ! I HAVE YET TO IMPLEMENT THE PVL AND WEARTIME CLEANING OF EACH FILE TYPE
# AND I ALSO HAVE TO INCLUDE THE SLEEP DATA HERE !

# empty environment
rm(list = ls())

# libraries
library(dplyr); library(ggplot2);library(ggnewscale);library(viridis);library(lubridate);library(readr)

# specify the week to compile (needs to match naming convention on synology)
week_indicator = "week_1"

# load redcap from CCH for uids and start and end times
redcap = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_data.csv") |>
  dplyr::mutate(starttime = ymd_hms(starttime),
                endtime   = ymd_hms(endtime),
                redcap_event_name = substr(redcap_event_name, 13,18)) |>
  filter(redcap_event_name == week_indicator)|>
  filter(!(uid %in% c("ACT029U", "ACT034X", "ACT045O")))|>
  filter(str_starts(uid, "ACT"))

# vector of all uids
uids <- unique(redcap$uid)

# file path to participants
filepath_part <- paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/", week_indicator,"/")

# empty dataframe for rbind in loop
df_CR <- data.frame()
df_HR <- data.frame()
df_HRV <- data.frame()
df_IBI <- data.frame()
df_STEPS <- data.frame()
df_Temp <- data.frame()

# loop over all participants
for(uidx in uids){
  
  print(uidx)
  
  # list the files in the folder of the participant
  files_uid <- list.files(paste0(filepath_part, uidx, "/"))
  
  # get individual files
  file_CR <- files_uid[grepl("CR", files_uid)]
  file_HR <- files_uid[grepl("HR_", files_uid)]
  file_HRV <- files_uid[grepl("HRV", files_uid)]
  file_IBI <- files_uid[grepl("IBI", files_uid)]
  file_STEPS <- files_uid[grepl("Steps", files_uid)]
  file_Temp <- files_uid[grepl("Temp", files_uid)]
  
  # rbind the files if they exist
  if(length(file_CR) != 0){
    data = read_csv(paste0(filepath_part, uidx, "/", file_CR))
    df_CR <- rbind(df_CR, data)
  }
  if(length(file_HR) != 0){
    data = read_csv(paste0(filepath_part, uidx, "/", file_HR))
    df_HR <- rbind(df_HR, data)
  }
  if(length(file_HRV) != 0){
    data = read_csv(paste0(filepath_part, uidx, "/", file_HRV))
    df_HRV <- rbind(df_HRV, data)
  }
  if(length(file_IBI) != 0){
    data = read_csv(paste0(filepath_part, uidx, "/", file_IBI))
    df_IBI <- rbind(df_IBI, data)
  }
  if(length(file_STEPS) != 0){
    data = read_csv(paste0(filepath_part, uidx, "/", file_STEPS))
    df_STEPS <- rbind(df_STEPS, data)
  }
  if(length(file_Temp) != 0){
    data = read_csv(paste0(filepath_part, uidx, "/", file_Temp))
    df_Temp <- rbind(df_Temp, data)
  }
}

# df_CR <- data.frame()
# df_HR <- data.frame()
# df_HRV <- data.frame()
# df_IBI <- data.frame()
# df_STEPS <- data.frame()
# df_Temp <- data.frame()

# save the cleaned but RAW resolution data
write_csv(df_CR, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/", week_indicator, "/", week_indicator, "_actigraph_CR_RAW.csv"))
write_csv(df_HR, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/", week_indicator, "/", week_indicator, "_actigraph_HR_RAW.csv"))
write_csv(df_HRV, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/", week_indicator, "/", week_indicator, "_actigraph_HRV_RAW.csv"))
write_csv(df_IBI, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/", week_indicator, "/", week_indicator, "_actigraph_IBI_RAW.csv"))
write_csv(df_STEPS, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/", week_indicator, "/", week_indicator, "_actigraph_Steps_RAW.csv"))
write_csv(df_Temp, paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data/Participants/", week_indicator, "/", week_indicator, "_actigraph_Temp_RAW.csv"))

