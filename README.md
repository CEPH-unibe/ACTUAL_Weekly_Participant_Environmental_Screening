# ACTUAL: weekly screening of the participant environmental and personal data

Author: Tino Schneidewind


### I answer the following questions in this App:

1. Who has been monitored per week/time-period? 
2. Which files are available per person?
3. What were the exposures of each person of the week?
4. Create a pdf-file for every time period that enables me to check what data is missing and if there are some major irregularities.


### Preparing this App locally
1. You need to save this repository within another folder because we cannot upload the data and reports to GitHub
2. in this master folder, create a data and reports folder
3. run the getREDCap.R file with the TOKEN to get the data, you need to refresh this data from time to time. Dont push the Token to GitHub!

### Running the App
-  select a time period of choice
-  select a participant that was started being observed in your selected time period to see the data
-  you can see all the files in the folder of the selected participant and the total number of files
-  with the download button you save plots of the data of all participants that were started being observed in the selected time period. Caution: when very long timeperiods are selected, plots can appear empty in the PDF even though there is data.
