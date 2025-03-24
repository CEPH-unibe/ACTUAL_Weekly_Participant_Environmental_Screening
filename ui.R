# Modify UI
ui <- fluidPage(
  
  # title
  titlePanel("Individual Level Data Screening"),
  
  # Sidebar 
  sidebarLayout(
    sidebarPanel(
      
      #  date range input
      dateRangeInput("date_range", 
                     label = "Select a time period:", 
                     start = Sys.time() - 7*24*60*60,  # Default start date
                     end = Sys.time()), # Default end date
      
      # dropdown for selecting UID
      selectInput("uid_select", 
                  "Select Participant for Plotting:", 
                  choices = NULL,  # This will be dynamically populated
                  selected = NULL),
      
      # Download button for PDF report
      downloadButton("download_pdf", "Download PDF Report"),
  
      
      textOutput("file_path"),
      
      # display the list of files in the folder
      uiOutput("file_list_ui"),
      
      # display the total number of files
      textOutput("total_files")),
    
    # Main panel displaying filtered data and plots
    mainPanel(
      tableOutput("filtered_data"),
      uiOutput("data_plot")
    )
  )
)