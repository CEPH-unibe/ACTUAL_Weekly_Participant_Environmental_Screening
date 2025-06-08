# The ACTUAL Project

[ACTUAL](https://www.ispm.unibe.ch/research/research_groups_and_themes/climate_epidemiology_and_public_health/index_eng.html#pane876954) (*Advancing research on extreme humid heat and health*) aims to advance knowledge about the impact of humid heat on human health through developing, diversifying, and applying new methodologies, data resources, and settings beyond existing current state-of-the-art approaches in climate epidemiology.

<br>

### Content of this repository

This repository includes the data management and processing of the ACTUAL project, a cohort study in The Gambia measuring temperature and humidity on and surrounding 80 participants over 4 seperate weeks in a sub-saharan climate.

<br>

# Processing Pipelines

A description of the processing and aggregation of of the output of different devices.

### REDCap

[REDCap](https://project-redcap.org/) logs metadata on the study procedure and measurements. In the getREDCap.R file I access REDCap via API and save the RAW output file as well as two aggregated versions on `CCH/Actual_project/data/App_Personal_Data_Screening/`.

### iButton (IB) data

The iButton data, saved on a Synology server, is first compiled rowwise for all variables combined, and additionally aggregated to hourly averages and then joined by columns. Both files (RAW rowwise and hourly averages with joined columns) are saved to `CCH/Actual_project/data-raw/Participants`.

Additionally to just compiling in RAW and hourly format, the RAW data is cleaned using the steps described in `vignettes/Data_Cleaning_Protocol_revised.Rmd`. This data is saved in RAW format through rbinding for every variable individually and again aggregated to hourly averages and joined through columns. Both clean file types (hourly aggregated and multiple variable RAW files) are saved in `CCH/Actual_project/data/Participants/week_1/`.

### Actigraph data

The Actigraph data from Synology is converted/prepared using the Actilife program, which is done outside of this repository and not part of it. 

The output from Actilife is then stored on `CCH/ACTUAL_project/raw-data/Actigraph/`. From the `CCH/../Actigraph/csv/` folder, first the RAW files are copied into the `CCH/..Actigraph/participant/week_1/uid/` folders of the respective participant. Using the GGIR package, the weartime validation is computed and saved in the `CCH/../Actigraph/uid/RAW_processed/` folder. This GGIR output is then copied into the `../uid/` folder and aggregated to hourly averages and saved in the same folder. Additionally, the GGIR output is compiled rowwise in both formats and saved into `CCH/Actual_project/data/Participants`. 

Next, the mutiple heart rate variables, steps and temperature files are copied from the `CCH/../Actigraph/` folder to their `CCH/..Actigraph/participants/week_1/uid/` folders before they are then compiled rowwise to individual variable files and saved in the /data/ folder. 

### Noise data

The noise data was compiled from Synology and saved as a RAW file without aggregation in the `CCH/Actual_project/data/Participants/` folder. From this RAW data, hourly, daily, and weekly indicators are calculated and saved as 3 individual files in the same folders. The indicators are described in `/vignettes/Noise_processing.Rmd`.


<br>

# Folders

### The app_cleaned data folder

Using this `app_cleaned` app, I compare the cleaned and aggregated IB data to unclean aggregated IB data to investigate the impact of cleaning before the aggregation. The processes of cleaning are described in the `vignettes/Data_Cleaning_Protocol_revised.Rmd` and then implemented in the `data_processing` folder in the workflow of the `iButton_...` files

### The app_weekly_cleaning_reports folder

I answer app: `app_weekly_cleaning_reports` the following questions in this App:

1. Who has been monitored per week/time-period? 
2. Which files are available per person?
3. What were the exposures of each person of the week?
4. Create a pdf-file for every time period that enables me to check what data is missing and if there are some major irregularities.

This app serves as a control for the measured data to ensure correct measurement intervals in line with the plan on REDCap. 

### The data processing folder

In the `data processing` folder I implement the data processing for the Actigraph data, the IB data and the noise sentry data. The data from REDCap can be updated on the `CCH` server using the `getREDCap.R` file.


### The vignettes folder

In the `vignettes` folder I demostrate multiple processes on example dataset that I then implemented in the data processing folder. This includes the data cleaning protocol for the IB (`Data_Cleaning_Protocol_revised.Rmd`), the use of the GGIR package for processing of accelerometer data from the Actigraph (`GGIR_Workflow.Rmd`), a Cleanliness report document the state of the data after the first week (`Cleanliness_Report.Rmd`), and how to prepare the noise data to get meaningful indices (`Noise_preparation.Rmd`). 


### The reports folder

In the `reports` is the output of the `app_weekly_cleaning_reports` app saved to enable future investigation of raw measured data without running the app again.

