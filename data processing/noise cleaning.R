### this document serves as a try out platform on a random participant to 
### create a script to 
### CLEAN THE NOISE SENTRY DATA


rm(list=ls())


# for handling file paths and different operating systems
source("functions.R")
source("MACorWIN.R")

# libraries
library(readr);library(tidyr);library(dplyr);library(readxl);library(zoo)
library(lubridate);library(stringr);library(ggplot2);library(gridExtra); library(grid)

# specify the week to compile (needs to match naming convention on synology)
week_indicator = "week_1"




# LOAD DATA
#---- 

# load redcap from CCH
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
  drop_na(pvl_start) |>
  filter(redcap_event_name == "study_visit_week_1_arm_1") |>
  filter(!(uid %in% c("ACT029U", "ACT034X", "ACT045O")))




# noise data
data_N <- data |>
  mutate(Variable = if_else(Variable == "_NS", "NS", Variable)) |>
  filter(Variable == "NS")|>
  pivot_wider(names_from = Variable, values_from = Value)|>
  mutate(
    NS_MA = rollmean(NS, k = 8, fill = NA, align = "left"))

# noise data for a specific participant
data_N_001 <- data_N |>
  filter(uid == "ACT001D")


#-------------------------------------------------------------------------------

ggplot(data_N_001, aes(x = datetime)) +
  geom_line(aes(y = NS)) +
  geom_point(aes(y = NS)) +
  labs(x = "time", y = "NS [dB]", title = "uncleaned noise data"
  ) +
  theme_minimal()

# STEP 1: Clean the raw data as described in: Land Use Regression Modeling of 
# Outdoor Noise Exposure in Informal Settlements in Western Cape, South Africa 
# https://www.mdpi.com/1660-4601/14/10/1262

# a)
# Restrict to the same weekly period for everyone. Identify start and end times for which everyone is being monitored.
# Time windows can be discussed based on data availability

redcap_001 <- redcap |>
  filter(uid == "ACT001D") |>
  mutate(dow_start = weekdays(pvl_start),
         dow_end = weekdays(pvl_end))

# this should be always MONDAY TO FRIDAY right?

# b)
# Exclude observations with >10% missing data (threshold to discuss depending on data availability)
# what do we consider an observation?

# c)
# Remove outliers, defined as one-minute noise measurements (=raw data) 
# exceeding the five-day mean by plus or minus three standard deviations.

mean_noise = mean(data_N_001$NS, na.rm = TRUE)
sd_noise = sd(data_N_001$NS, na.rm = TRUE) * 3

data_N_001 <- data_N_001 |>
  mutate(
    NS_outliers = ifelse(NS > mean_noise + sd_noise | NS < mean_noise - sd_noise, TRUE, FALSE)
  )

ggplot(data_N_001, aes(x = datetime)) +
  geom_line(aes(y = NS)) +
  geom_point(aes(y = NS, color = as.factor(NS_outliers))) +
  scale_color_manual(values = c("FALSE" = "black", "TRUE" = "red")) +
  labs(x = "time", y = "NS [dB]", title = "Uncleaned Noise Data", color = "Outlier") +
  theme_minimal()


# STEP 2: 2)	Calculate noise indicators (long-term):  A-weighted equivalent sound level 
# variables as described here: Space-time characterization of community noise and sound sources in
# Accra, Ghana | Scientific Reports https://www.nature.com/articles/s41598-021-90454-6#Fig1






