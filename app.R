################################################################################
### WEEKLY SCREENING OF INDIVIDUAL LEVEL DATA
################################################################################


rm(list=ls())



# libraries
library(shiny);library(readr);library(tidyr);library(dplyr)



# data

## redcap





# load user interface and server
ui     <- source("ui.R")
server <- source("server.R")


# run the app
shinyApp(ui = ui, server = server)


