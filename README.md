# ACTUAL: weekly screening of the participant environmental and personal data

Author: Tino Schneidewind


### I answer the following questions in this App:

1. Who has been monitored per week/time-period? 
2. Which files are available per person?
3. What were the exposures of each person of the week?
4. Create a pdf-file for every time period that enables me to check what data is missing and if there are some major irregularities.


### Preparing this App locally
- All the data is on the CCH server. For the App to run you need to be connected to it. If you want to make sure you have the latest update of th REDCap data you might need to refresh the data on the server using the data processing/getREDCap.R file and with the token to access the API. Please make sure to NOT COMMIT THE TOKEN!

### Running the App
- open the app.R file and run all the lines of code -> the app should open automatically
-  select a time period of choice
-  select a participant that was started being observed in your selected time period to see the data
-  you can see all the files in the folder of the selected participant and the total number of files
-  with the download button you save plots of the data of all participants that were started being observed in the selected time period. Caution: when very long timeperiods are selected, plots can appear empty in the PDF even though there is data.
jidsgf

sadas
