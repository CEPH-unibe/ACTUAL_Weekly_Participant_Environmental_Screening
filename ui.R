# Modify UI
ui <- fluidPage(
  
  tags$style(HTML("
  .sidebar-panel-custom {
    margin-bottom: 20px; /* Controls spacing between sidebar elements */
  }
")),
  
  # title
  titlePanel("Individual Level Data Screening"),
  
  # Sidebar 
  sidebarLayout(
    sidebarPanel(
      
      #  date range input
      dateRangeInput("date_range", 
                     label = "Select a time period:", 
                     # start = "2025-01-12 00:00:00",  # fixed dates for testing
                     # end = "2025-01-19 23:59:59"), # 
                     start = Sys.time() - 7*24*60*60,  # Default start date
                     end = Sys.time()), # Default end date

      # dropdown for selecting UID
      selectInput("uid_select", 
                  "Select Participant for Plotting:", 
                  choices = NULL,  # This will be dynamically populated
                  selected = NULL),
      

  
      
      textOutput("file_path"),
      
      br(),
      
      # display the list of files in the folder
      uiOutput("file_list_ui"),
      
      br(),
      
      # display the total number of files
      textOutput("total_files"),   
      
      br(),
      
      # Download button for PDF report
      downloadButton("download_pdf", "Download PDF Report")),
    
    # Main panel displaying filtered data and plots
    mainPanel(
      tableOutput("filtered_data"),
      uiOutput("data_plot")
    )
  )
)