# ACTUAL: data processing

Author: Tino Schneidewind

### Contents
this repository investigates raw and processed data, developes methods for cleaning and processes the data accordingly



## Folders

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

