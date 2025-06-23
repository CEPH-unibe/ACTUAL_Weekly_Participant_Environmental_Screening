

# ---- USER OPTIONS ----
# Set which outputs you want to generate
generate_hr  <- TRUE   # Heart Rate
generate_hrv <- TRUE   # Heart Rate Variability
generate_cr  <- FALSE  # Cardiac Rhythm
generate_ibi <- FALSE   # Inter-Beat Interval
# -----------------------

# Define paths
hr_exe <- "data processing/Actigraph_XX_HR_caclulation.exe"
input_dir <- "/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/csv"
output_dir <- "/Volumes/FS/_ISPM/CCH/Actual_Project/data-raw/Actigraph/HR"

# Get all RAW.csv files
raw_files <- list.files(input_dir, pattern = "RAW\\.csv$", full.names = TRUE)

# Loop over each file and process it
for (raw_csv in raw_files) {
  # browser()
  base_name <- sub("(\\))RAW\\.csv$", "\\1", basename(raw_csv))
  
  # Construct all possible output paths
  ppg_csv <- file.path(input_dir, paste0(base_name, "ppg25Hz.csv"))
  hr_csv  <- file.path(output_dir, paste0(base_name, "_HeartRate.csv"))
  hrv_csv <- file.path(output_dir, paste0(base_name, "_HeartRateVar.csv"))
  cr_csv  <- file.path(output_dir, paste0(base_name, "_CardiacRhythm.csv"))
  ibi_csv <- file.path(output_dir, paste0(base_name, "_InterBeatInterval.csv"))
  
  # Check if any selected output is missing
  needs_processing <- (
    (generate_hr  && !file.exists(hr_csv))  ||
      (generate_hrv && !file.exists(hrv_csv)) ||
      (generate_cr  && !file.exists(cr_csv))  ||
      (generate_ibi && !file.exists(ibi_csv))
  )
  
  if (needs_processing) {
    # Construct command arguments dynamically
    args <- c("-a", shQuote(raw_csv), "-p", shQuote(ppg_csv), "-z", "CET")
    
    if (generate_hr)  args <- c(args, "-e", shQuote(hr_csv))
    if (generate_hrv) args <- c(args, "-u", shQuote(hrv_csv))
    if (generate_cr)  args <- c(args, "-b", shQuote(cr_csv))
    if (generate_ibi) args <- c(args, "-i", shQuote(ibi_csv))
    
    # Run the command
    system2(hr_exe, args = args, wait = TRUE)
    cat("Processed:", raw_csv, "\n")
  } else {
    cat("Skipped (selected outputs exist):", raw_csv, "\n")
  }
}








# ------------------------------------------------------------------------------------------------
# OLD
# ------------------------------------------------------------------------------------------------

# Define paths
hr_exe <- "code/hr_1.1.0/hr_1.1.0.exe"
hr_exe <- "code/hr/hr.exe"
# input_dir <- "Y:/CCH/Actual_Project/data-raw/Actigraph/csv"
input_dir <- "Y:/CCH/Actual_Project/data-raw/Actigraph/csv"
output_dir <- "Y:/CCH/Actual_Project/data-raw/Actigraph/HR"

# Get all RAW.csv files
raw_files <- list.files(input_dir, pattern = "RAW\\.csv$", full.names = TRUE)

# Loop over each file and process it
for (raw_csv in raw_files[5]) {
  # Extract base filename (without extension)
  base_name <- tools::file_path_sans_ext(basename(raw_csv))
  base_name <- sub("(\\))RAW\\.csv$", "\\1", basename(raw_csv))
  
  # Construct output file paths
  ppg_csv  <- file.path(input_dir, paste0(base_name, "ppg25Hz.csv"))
  hr_csv   <- file.path(output_dir, paste0(base_name, "_HeartRate.csv"))
  hrv_csv  <- file.path(output_dir, paste0(base_name, "_HeartRateVar.csv"))
  cr_csv   <- file.path(output_dir, paste0(base_name, "_CardiacRhythm.csv"))
  ibi_csv  <- file.path(output_dir, paste0(base_name, "_InterBeatInterval.csv"))
  
  # Check if at least one of the output files is missing - will run only for new files
  if (!file.exists(ppg_csv) || !file.exists(hr_csv) || 
      !file.exists(hrv_csv) || !file.exists(cr_csv) || 
      !file.exists(ibi_csv)) {
  
    # Run the command
    system2(hr_exe, args = c("-a", shQuote(raw_csv), "-p", shQuote(ppg_csv), "-z", "CET",
                             "-e", shQuote(hr_csv), "-u", shQuote(hrv_csv), "-b", 
                             shQuote(cr_csv), "-i", shQuote(ibi_csv)), 
            wait = TRUE)
    
    # Print status
    cat("Processed:", raw_csv, "\n")
  }
  else{
    cat("Skipped (outputs exist):", raw_csv, "\n")
  }
}
