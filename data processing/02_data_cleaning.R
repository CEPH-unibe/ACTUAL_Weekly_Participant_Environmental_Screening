###############################################################################
# DATA CLEANING SCRIPT BASED ON vignettes/Data_Cleaning_Protocol_revised.Rmd


rm(list=ls())


# for handling file paths and different operating systems
source("functions.R")
source("MACorWIN.R")

# libraries
library(readr);library(tidyr);library(dplyr);library(readxl);library(zoo)
library(lubridate);library(stringr);library(ggplot2);library(gridExtra); library(grid)


# LOAD and SPLIT DATA
#----
if(MACorWIN == 0){
  
  # iButton and Noise data
  data <- read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Participants/week1_minute_data_unclean.csv")
  
  # REDCap for uids and start and end times
  redcap = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_all.csv")
  
  } else {
    
    # iButton and Noise data
    data <- read_csv("Y:/CCH/Actual_Project/data-raw/Participants/week1_minute_data_unclean.csv")
    
    # REDCap for uids and start and end times
    redcap = read_csv("Y:/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_all.csv")
  }

# select redcap data 
redcap <- redcap |> 
  select(uid, redcap_event_name, pvl_start, pvl_end, starts_with("pvl_ib")) |>
  drop_na(pvl_start)

# house data
data_H <- data |>
  filter(Variable == "IBH_HUM" | Variable == "IBH_TEMP")|>
  pivot_wider(names_from = Variable, values_from = Value)


# worn data
data_W <- data |>
  filter(Variable == "IBW_HUM" | Variable == "IBW_TEMP")|>
  pivot_wider(names_from = Variable, values_from = Value)|>
  mutate(
    IBW_HUM_MSD = rollapply(IBW_HUM, width = 3, FUN = sd, align = "left", fill = NA)
  ) 

# taped data
data_T <- data |>
  filter(Variable == "IBT_TEMP")|>
  pivot_wider(names_from = Variable, values_from = Value) 

# noise data
data_N <- data |>
  mutate(Variable = if_else(Variable == "_NS", "NS", Variable)) |>
  filter(Variable == "NS")|>
  pivot_wider(names_from = Variable, values_from = Value)|>
  mutate(
    NS_MA = rollmean(NS, k = 8, fill = NA, align = "left"))


#----


# CLEANING
# 1. PVL-VISITS
# First, data has to be excluded that was taken outside the observation window
# and during personal visit log times if the devices were changed.
# The data was cut to the observation window in the data compiling but the checking 
# whether the device was changed will be done here.

# loop through uids
for(uids in unique(redcap$uid)){
  
  redcap_subset <- redcap[redcap$uid == uids,]
  
  # loop through pvl visits
  for(i in nrow(redcap_subset)) {
    
    
    startvalue <- redcap_subset$pvl_start[i]
    endvalue <-  redcap_subset$pvl_end[i]
    
    # if house Ibutton was changed
    if(redcap_subset$pvl_ibuthouse[i] == 1 ){
      
      # set values to NA
      data_H <- data_H |>
        mutate(IBH_HUM = if_else(uid %in% uids & datetime > startvalue & datetime < endvalue, NA, IBH_HUM),
               IBH_TEMP = if_else(uid %in% uids & datetime > startvalue & datetime < endvalue, NA, IBH_TEMP))
    }
    
    # if worn Ibutton was changed
    if(redcap_subset$pvl_ibutworn[i] == 1 ){
      
      # set values to NA
      data_W <- data_W |>
        mutate(IBW_HUM = if_else(uid %in% uids & datetime > startvalue & datetime < endvalue, NA, IBW_HUM),
               IBW_TEMP = if_else(uid %in% uids & datetime > startvalue & datetime < endvalue, NA, IBW_TEMP),
               IBW_HUM_MSD = if_else(uid %in% uids & datetime > startvalue & datetime < endvalue, NA, IBW_HUM_MSD))
    }
    
    # if taped Ibutton was changed
    if(redcap_subset$pvl_ibuttaped[i] == 1 ){
      
      # set values to NA
      data_T <- data_T |>
        mutate(IBT_TEMP = if_else(uid %in% uids & datetime > startvalue & datetime < endvalue, NA, IBT_TEMP))
    }
  }
}


# 2. Physically possible
# Every Variable (temperature, RH, noise) has its physical limits that the following:
#   
#   1. Temperature: < -273 °C
#   2. RH: < 0 % and > 100 %
#   3. Noise: < 0 dB

# House
data_H <- data_H |>
  mutate(IBH_TEMP = if_else(IBH_TEMP < -273, NA, IBH_TEMP),
         IBH_HUM = if_else(IBH_HUM < 0 | IBH_HUM > 100, NA, IBH_HUM))

# Worn
data_W <- data_W |>
  mutate(IBW_TEMP = if_else(IBW_TEMP < -273, NA, IBW_TEMP),
         IBW_HUM = if_else(IBW_HUM < 0 | IBW_HUM > 100, NA, IBW_HUM))

# Taped
data_T <- data_T |>
  mutate(IBT_TEMP = if_else(IBT_TEMP < -273, NA, IBT_TEMP))

# Noise
data_N <- data_N |>
  mutate(NS = if_else(NS < 0, NA, NS))



# 3. Physically plausible
# The plausible range is to some degree subjective, depends on the observation surroundings and changes not only depending on the variable, but also what the variable describes (temperature taped and house). Therefore now we need to start with device specific variable value ranges. 
# 
# 1. House: Temperature < 0 °C and > 55 °C, RH: no additional filtering
# 2. Worn: Temperature < 10 °C and > 45 °C, RH: no additional filtering
# 3. Taped: Temperature below the 10th percentile (no upper filtering because taped temperature almost always is greater than house temperature) (25th percentile was too high)
# 4. Noise: no additional filtering

# House
data_H <- data_H |>
  mutate(IBH_TEMP = if_else(IBH_TEMP < 0 | IBH_TEMP > 55, NA, IBH_TEMP))

# Worn
data_W <- data_W |>
  mutate(IBW_TEMP = if_else(IBW_TEMP < 15 | IBW_TEMP > 45, NA, IBW_TEMP))

# Taped
thrsh = quantile(data_T$IBT_TEMP, .10)
data_T <- data_T |>
  mutate(IBT_TEMP = if_else(IBT_TEMP < thrsh, NA, IBT_TEMP))


# 4. Variability 
# We do want to filter out worn measurements that resemble the variance of the house measurements 
# and indicate the the device was not worn. We use the moving standard deviation of 3 left aligned 
# humidity values. As an additional measure to prevent filtering out reasonable values, we filter 
# only measurements if the standard deviation has been too low for 4 consecutive measurements. 
thrsh = 0.75

# Worn
data_W <- data_W |>
  mutate(IBW_HUM_thrsh = if_else(IBW_HUM_MSD < thrsh, 1, 0),
         IBW_HUM_MA_thrsh = rollmean(IBW_HUM_thrsh, k = 4, fill = NA, align = "left"),
         IBW_TEMP = if_else(IBW_HUM_MA_thrsh == 1, NA, IBW_TEMP),
         IBW_HUM = if_else(IBW_HUM_MA_thrsh == 1, NA, IBW_HUM))


#----


# next steps

# 1. create hourly averages and then cbind all variables
# 2. look at the hourly averages by uid
# 3. save the data on CCH
# 4. write the Cleanliness report














