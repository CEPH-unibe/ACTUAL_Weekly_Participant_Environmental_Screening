# ACTUAL: data processing

Author: Tino Schneidewind

### Contents
this repository investigates raw and processed data, developes methods for cleaning and processes the data accordingly

<br>

# Processing Pipelines

A description of the processing and aggregation of of the output of different devices.

### REDCap

In the gerREDCap.R file I access REDCap via API and save the RAW output file as well as two aggregated versions in data/App_Personal_Data_Screening/.

### iButton (IB) data

The iButton data from Synology is first compiled rowwise for all variables combined, and additionally aggregated to hourly averages and then joined by columns. Both files (RAW rowwise and hourly averages with joined columns) are saved to CCH/Actual_project/data-raw/Participants.

Additionally to just compiling in RAW and hourly format, the RAW data is cleaned using the steps described in /vignettes/Data_Cleaning_Protocol_revised.Rmd. This data is saved in RAW format through rbinding for every variable individually and again aggregated to hourly averages and joined through columns. Both clean file types (hourly aggregated and multiple variable RAW files) are saved in data/Participants/week_1/.

### Actigraph data

The Actigraph data from Synology is converted/prepared using the Actilife program, which is done outside of this repository and not part of it. 

The output from Actilife is then stored on CCH/ACTUAL_project/raw-data/Actigraph/. From the /csv/ folder, first the RAW files are copied into the /participant/week_1/uid/ folders of the respective participant. Using the GGIR package, the weartime validation is computed and saved in the /uid/RAW_processed/ folder. This GGIR output is then copied into the /uid/ folder and aggregated to hourly averages and saved in the same folder. Additionally, the GGIR output is compiled rowwise in both formats and saved into CCH/Actual_project/data/Participants. 

Next, the mutiple heart rate variables, steps and temperature files are copied from the /Actigraph/ folder to their /participants/week_1/uid/ folders before they are then compiled rowwise to individual variable files and saved in the /data/ folder. 

### Noise data

The noise data was compiled from Synology and saved as a RAW file without aggregation in the CCH/Actual_project/data/Participants/ folder. From this RAW data, hourly/daily/weekly indicators are calculated and saved as 3 individual files in the same folders. The indicators are described in /vignettes/Noise_processing.Rmd.


<br>

# Folders

### /app_cleaned data

Using this app, I compare the cleaned and aggregated IB data to aggregated IB data to investigate the impact of cleaning before the aggregation. The processes of cleaning are described in the vignette Data_Cleaning_Protocol_revised.Rmd and then implemented in the data_processing folder in the workflow of the iButton_... files

### /app_weekly_cleaning_reports

I answer the following questions in this App:

1. Who has been monitored per week/time-period? 
2. Which files are available per person?
3. What were the exposures of each person of the week?
4. Create a pdf-file for every time period that enables me to check what data is missing and if there are some major irregularities.

This app serves as a control for the measured data to ensure correct measurement intervals in line with the plan on REDCap and is not missing. 

### /data processing

Here I implement the data processing for the Actigraph data, the IB data and the noise sentry data. The data from REDCap can be updated on the CCH server using the getREDCap.R file.


### /vignettes

Here I demostrate multiple processes on example dataset that I then implemented in the data processing folder. This includes the data cleaning protocol for the IB (revised version), the use of the GGIR package for processing of accelerometer data from the Actigraph, a Cleanliness report document the state of the data after the first week, and how to prepare the noise data to get meaningful indices. 


### /reports

Here is the output of the app_weekly_cleaning_reports saved to enable future investigation of raw measured data without running the App again.

