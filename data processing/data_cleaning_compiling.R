
rm(list=ls())


source("functions.R")

library(readr);library(tidyr);library(dplyr);library(readxl)
library(lubridate);library(stringr);library(ggplot2);library(gridExtra); library(grid)


source("MACorWIN.R")

if(MACorWIN == 0){
  
  # REDCap for uids and start and end times
  redcap = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_data.csv") |>
    dplyr::mutate(starttime = ymd_hms(starttime),
                  endtime   = ymd_hms(endtime),
                  redcap_event_name = substr(redcap_event_name, 13,18))
  
  # REDCap for exclusion of pvls
  redcap_pvl = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_pvl.csv") |>
    dplyr::mutate(redcap_event_name = substr(redcap_event_name, 13,18))

  
} else {
  
  # REDCap for uids and start and end times
  redcap = read_csv("Y:/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_data.csv") |>
    dplyr::mutate(starttime = ymd_hms(starttime),
                  endtime   = ymd_hms(endtime),
                  redcap_event_name = substr(redcap_event_name, 13,18))
  
  # REDCap for exclusion of pvls
  redcap_pvl = read_csv("Y:/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_pvl.csv") |>
    dplyr::mutate(redcap_event_name = substr(redcap_event_name, 13,18))
  

  
}



data_full <- data.frame(uid      = "ACT",
                        datetime = redcap$starttime[1],
                        Value = 120,
                        Variable = "IBX")


indicators <- data.frame(place = c("IBH", "IBH", "IBT", "IBW", "IBW", ""),
                         variable = c("HUM", "TEMP", "TEMP", "HUM", "TEMP", "NS"))



# loop through uids
for (uid in unique(redcap$uid)) {
  
  if(MACorWIN == 0){
  # extract all the files for every uid
  files_all <- list.files(paste0("~/SynologyDrive/Participants/", uid, "/week1/"), full.names = TRUE)  
  } else {
    files_all <- list.files(paste0(Sys.getenv("HOME"), "/SynologyDrive/Participants/", uid, "/week1/"), full.names = TRUE)  
  }
    
  # only continue if the folder is not emty
  if (length(files_all) > 0) {
    
    
    # loop through all dataset indicators
    for (placevar in 1:nrow(indicators)) {
      
      place = indicators[placevar,1]
      variable = indicators[placevar,2]
      
      
      # extract file name for indicators
      file <- files_all[grepl(place, files_all) & grepl(variable, files_all)]
      
      # only continue of the chosen excel file is not empty
      if (length(file) > 0) {
        
        # remove temp/hidden files         
        file <- file[!grepl("^~\\$", basename(file))]  
        
        # ensure we only pick the **first valid file** (if multiple exist)
        file <- file[1]
        
        # Read the data
        if (file.exists(file)) {  # Double-check file exists
          
          
          
          
          
          # distinguish between noise and other files in assigning cols
          if(variable != "NS"){
            
            # Read the Excel file
            data <- read_excel(file)
            
            # find the row number where "Date" and "Time" are located
            header_row <- which(data[, 1] == "Date" & data[, 2] == "Time" )
            
            data <- read_excel(file, skip = header_row) |>
              dplyr::mutate(datetime = ymd_hms(paste(Date, Time)),
                            Value = as.numeric(Value),
                            uid = uid,
                            Variable = paste0(place,"_",variable)) |>
              select(uid, datetime, Value, Variable)
          } else {
            # print("HALLO")
            
            data <- read.delim(file, skip = 2, header = TRUE)  
            
            colnames(data) <- c("datetime", "Value")
            
            data <- data[,1:2] |>
              dplyr::mutate(uid = uid,
                            Variable = paste0(place,"_",variable)) |>
              select(uid, datetime, Value, Variable)
          }
          
          # exclude data before/after the pvl's
          start_time <- redcap$starttime[redcap$uid == uid]
          end_time <- redcap$endtime[redcap$uid == uid]
          
          data <- data |>
            filter(datetime >= start_time & datetime <= end_time)
          
          # # exclude data during pvls
          # redcap_subset <- redcap_pvl[redcap_pvl$uid == uid,]
          # 
          # for(i in 2:(nrow(redcap_subset)-1)){
          #   
          #   # set values during pvls to na
          #   data <- data |>
          #     mutate(across(Value, 
          #       ~ if_else(datetime >= redcap_subset$pvl_start[i] & datetime <= redcap_subset$pvl_end[i], NA, .x)
          #     ))  
          #   
          #   
          # }
          
          
          # assign to the right column based on datetime
          data_full <- rbind(data_full, data) 
        }
      } 
    }
  }
}



if(MACorWIN == 0){
  # write the data to csv 
  write_csv(data_full, "/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/week1_minute_data_unclean.csv")
  
  
} else {
  
  # write the data to csv 
  write_csv(data_full, "Y:/CCH/Actual_Project/data/App_Personal_Data_Screening/week1_minute_data_unclean.csv")
  
}


# hourly averages
# Calculate hourly averages
data_hourly <- data_full %>%
  mutate(hour = floor_date(ymd_hms(datetime), "hour")) %>%  # Round datetime to the nearest hour
  group_by(uid, hour, Variable) %>%               # Group by UID, hour, and Variable
  summarise(Value_avg = mean(Value, na.rm = TRUE), .groups = "drop")  # Calculate mean


# unique files with hourly averages
data_H <- data_hourly |>
  filter(Variable == "IBH_HUM" | Variable == "IBH_TEMP") |>
  pivot_wider(names_from = Variable, values_from = Value_avg) |>
  mutate(id_time = paste0(uid, hour))

data_T <- data_hourly |>
  filter(Variable == "IBT_TEMP") |>
  mutate(id_time = paste0(uid, hour))

data_W <- data_hourly |>
  filter(Variable == "IBW_HUM" | Variable == "IBW_TEMP")|>
  pivot_wider(names_from = Variable, values_from = Value_avg)|>
  mutate(id_time = paste0(uid, hour))

data_N <- data_hourly |>
  filter(Variable == "_NS")|>
  mutate(id_time = paste0(uid, hour))

# combine hourly datasets.
data_combined <- data_H %>%
  full_join(data_W %>% select(id_time, IBW_HUM, IBW_TEMP), by = "id_time") %>%
  full_join(data_T %>% select(id_time, IBT_TEMP = Value_avg), by = "id_time") %>%
  full_join(data_N %>% select(id_time, NS = Value_avg), by = "id_time")



if(MACorWIN == 0){
  
  # write the data to csv 
  write_csv(data_combined, "/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/week1_hourly_data_unclean.csv")
  
  
} else {
  
  # write the data to csv 
  write_csv(data_combined, "Y:/CCH/Actual_Project/data/App_Personal_Data_Screening/week1_hourly_data_unclean.csv")
  
  
}










