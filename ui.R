# user interface
ui <- fluidPage(
  
  # title
  titlePanel("Individual Level Data Screening"),
  
  # Sidebar with date range input
  sidebarLayout(
    sidebarPanel(
      dateRangeInput("date_range", 
                     label = "Select a time period:", 
                     start = ymd("2024-09-27"),  # Default start date
                     end = Sys.time()), # Default end date
      
      # Dropdown for selecting UID
      selectInput("uid_select", 
                  "Select Participant for Ploting:", 
                  choices = NULL,  # This will be dynamically populated
                  selected = NULL),
      textOutput("file_path"),
      
      # Display the list of files in the folder
      uiOutput("file_list_ui"),
      
      # Display the total number of files
      textOutput("total_files")
    ),
    
    # Main panel displaying selected date range and filtered data
    mainPanel(
      tableOutput("filtered_data"),
      uiOutput("data_plot")
    )
  )
)



