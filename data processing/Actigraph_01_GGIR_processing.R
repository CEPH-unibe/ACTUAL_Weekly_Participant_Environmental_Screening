# In this document I will take all the necessary steps to run a get the hourly validation 
# data from the .RAW file using GGIR.

rm(list=ls())
library(dplyr); library(ggplot2);library(ggnewscale);library(viridis);library(stringr);library(lubridate)
library(readr); library(GGIR)


# for handling file paths and different operating systems
source("functions.R")

# specify the week to compile (needs to match naming convention on synology)
week_indicator = "week_1"

# load redcap from CCH
  # REDCap for uids and start and end times
  redcap = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_all.csv") |> 
    filter(str_starts(uid, "ACT"))


# I need to create a folder in which all the participants have individual folders
# in which I will move the .RAW file and then the output will be created in.


# STEP 1

# create the subfolders using the uids from redcap
uids <- unique(redcap$uid)


# for (uid in uids) {
#   folderpath <- paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/", uid)
#   
#   dir.create(folderpath)
# }


# Step 2
# copy the .RAW files from the csv folder only of week_1 to the corresponding folder
# files <- list.files("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/", 
#                     pattern = "ACT.*week1.*RAW.*\\.csv$", 
#                     full.names = TRUE)
# 
# for (uid in uids) {
#   
#   # select the file for every uid
#   selected_file <- files[grepl(uid, basename(files))]
#   
#   # define the output location
#   output_loc <- paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/",uid, "/", basename(selected_file)) 
# 
#   
#   file.copy(from = selected_file, 
#             to = output_loc)
# }



# Step 3 
# Run GGIR for every RAW file in every folder

# completed for all

# for (uid in uids) { # commented out for safety
  
  # print(uid)
  datadir = paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/week_1/", uid, "/") 
  
  # create output folder
  folderpath <- paste0(datadir, "RAW_processed")
  if (!dir.exists(folderpath)) dir.create(folderpath)
  
  outputdir = paste0(folderpath, "/")
  
  # check if RAW file exists (assuming file name is RAW.csv)
  rawfile <- list.files(datadir, pattern = "\\.csv$", full.names = TRUE)
  
  if (length(rawfile) == 0) {
    message(paste("No RAW file found for", uid, "- skipping."))
    next  # skip to next iteration
  }
  
  tryCatch({
    GGIR(
      mode = c(1, 2, 3, 4, 5),
      datadir = datadir,
      outputdir = outputdir,
      dataformat = "csv",
      csv.format = "actilife",
      csv.acc.col.acc = 2:4,
      csv.header = TRUE,
      csv.time.col = 1,
      csv.IDformat = 3,
      csv.col.names = TRUE,
      do.cal = TRUE,
      do.enmo = TRUE,
      strategy = 1,
      do.part3.sleep.analysis = TRUE,
      epochvalues2csv = TRUE,
      epochvalues2csv_minutes = 60,
      save_ms5rawlevels = TRUE,
      save_ms5raw_format = "csv",
      part5_agg2_60seconds = TRUE
    )
  }, error = function(e) {
    message(paste("Error processing", uid, ":", e$message))
  })
  
  gc()
}
