# In this document I will take all the necessary steps to run a get the hourly validation 
# data from the .RAW file using GGIR.

rm(list=ls())
library(dplyr); library(ggplot2);library(ggnewscale);library(viridis);library(stringr);library(lubridate)
library(readr); library(GGIR)


# for handling file paths and different operating systems
source("functions.R")

# specify the week to compile (needs to match naming convention on synology)
week_indicator = "week_2"

# load redcap from CCH
# REDCap for uids and start and end times
redcap = read_csv("/Volumes/FS/_ISPM/CCH/Actual_Project/data/App_Personal_Data_Screening/redcap_data.csv") |>
  dplyr::mutate(starttime = ymd_hms(starttime),
                endtime   = ymd_hms(endtime),
                redcap_event_name = substr(redcap_event_name, 13,18)) |>
  filter(redcap_event_name == week_indicator)|>
  filter(!(uid %in% c("ACT029U", "ACT034X", "ACT045O"))) |>
  filter(str_starts(uid, "ACT"))



# STEP 1

# create the subfolders using the uids from redcap
uids <- unique(redcap$uid)

for (uid in uids) {
  folderpath <- paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/", week_indicator, "/", uid)
  
  if (!dir.exists(folderpath)) {
    dir.create(folderpath, recursive = TRUE)
  }
}



# Step 2
# copy the .RAW files from the csv folder only of week_1 to the corresponding folder
files <- list.files("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv/",
                    pattern = "ACT.*week2.*RAW.*\\.csv$", # CAREFUL - WEEK INDICATOR!!
                    full.names = TRUE)

for (uid in uids) {
  
  # select the file for the current uid
  selected_file <- files[grepl(uid, basename(files))]
  
  # skip if no matching file is found
  if (length(selected_file) == 0) next
  
  # define output location
  output_loc <- file.path("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants",
                          week_indicator, uid, basename(selected_file))
  
  # only copy if file doesn't already exist
  if (!file.exists(output_loc)) {
    file.copy(from = selected_file, to = output_loc)
  }
}



# Step 3 
# Run GGIR for every RAW file in every folder

# completed for all

for (uid in uids) { # commented out for safety
  
  # print(uid)
  datadir = paste0("/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/participants/", week_indicator, "/", uid, "/") 
  
  # create output folder
  folderpath <- paste0(datadir, "RAW_processed")
  
  
  # Skip if RAW_processed folder exists and is not empty
  if (dir.exists(folderpath) && length(list.files(folderpath)) > 0) {
    message(paste("RAW_processed already populated for", uid, "- skipping."))
    next
  }
  
  
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
