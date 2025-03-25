################################################################################
### DOWNLOAD OF REDCAP DATA
################################################################################

# the purpose of this file:
# avoid repeatedly loading the redcap data through API
# select only necessary columns and get needed start and end times 
# save the data locally in the folder above of the Git repository so that it is
# not uploaded
# rerun this file if you want to update the redcap data

# WARNING !!!!!
# DELETE THE REDCAP TOKEN AFTER USE
# DONT SAVE THIS FILE WITH THE TOKEN


library(httr)
library(jsonlite)


rm(list=ls())


# load REDCap data
api_url <- "https://redcap.mrc.gm:8443/redcap/api/"
api_token <- ""     # WARNING -> DELETE TOKEN

# Create the request body
post_body <- list(
  token = api_token,
  content = "record",
  format = "json",
  type = "flat"
)

# Send the API request
response <- POST(api_url, body = post_body, encode = "form")

# Check response status
if (http_status(response)$category == "Success") {
  # Parse JSON response
  data <- fromJSON(content(response, "text"))
  print("Data successfully retrieved")
  # print(head(data))  # Display first few records
} else {
  print("Error in API request:")
  print(content(response, "text"))
}

# select necessary columns and convert to datetime
# return min pvl_end as a start time of the observation week
# return max pvl_start as a end time of the observation week
data <- data |>
  
  filter(str_detect(redcap_event_name, "study_visit_week")) |>
  
  select(uid,
         redcap_event_name,
         pvl_start,
         pvl_end) |>
  
  mutate(pvl_start = ymd_hm(pvl_start),
         pvl_end   = ymd_hm(pvl_end)) |>
  
  group_by(uid, redcap_event_name) |>
  
  summarise(starttime = min(pvl_end, na.rm = TRUE),
            endtime   = max(pvl_start, na.rm = TRUE),
            .groups   = "drop")

# Save dataset
write.csv(data, "../data/redcap_data.csv", row.names = FALSE)
