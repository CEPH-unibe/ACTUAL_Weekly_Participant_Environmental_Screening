# server logic
server <- function(input, output, session) {  # session is added here
  
  # Filter data based on date range
  filtered_data <- reactive({
    req(input$date_range)  # Ensure input is available
    
    data_filtered <- redcap %>%
      filter(as.Date(starttime) >= input$date_range[1] & 
               as.Date(starttime) <= input$date_range[2]) %>%
      mutate(starttime = format(starttime, "%Y-%m-%d %H:%M:%S"),
             endtime = format(endtime, "%Y-%m-%d %H:%M:%S")) 
    
    # Update UID selectInput choices based on the filtered data
    updateSelectInput(session, "uid_select", 
                      choices = unique(data_filtered$uid),  # Unique UID values
                      selected = unique(data_filtered$uid)[1])  # Initially select the first UID
    
    return(data_filtered)
  })
  
  # Render filtered data table
  output$filtered_data <- renderTable({
    filtered_data() 
  }, rownames = TRUE)
  
  
  # Observe when a UID is selected and generate the file path
  observeEvent(input$uid_select, {
    # Get the selected UID
    selected_uid <- input$uid_select
    
    # Get the corresponding redcap_event_name for the selected UID
    redcap_event <- filtered_data() |>
      filter(uid == selected_uid) |>
      pull(redcap_event_name)
    
    # Create the file path based on UID and redcap_event_name
    file_path <- paste0("~/SynologyDrive/Participants/", selected_uid, "/", 
                        gsub("_", "", redcap_event)
                        , "/")
    
    # Output the file path to the UI
    output$file_path <- renderText({
      paste("File Path: ", file_path)
    })
    
    # List files in the folder
    files_in_folder <- list.files(file_path, full.names = TRUE)  # List files in the directory
    
    # Find the common prefix in the file paths
    common_prefix_path <- common_prefix(files_in_folder)
    
    # Remove the common prefix from each file path
    files_in_folder_unique <- sub(common_prefix_path, "", files_in_folder)
    
    # Display the list of files
    output$file_list_ui <- renderUI({
      if (length(files_in_folder) > 0) {
        # If there are files, display them in a list
        tagList(
          h4("Files in Folder:"),
          tags$ul(lapply(files_in_folder_unique, function(file) {
            tags$li(file)  # Create list items with the unique part of the file paths
          }))
        )
      } else {
        # If no files, display a message
        h4("No files found in this folder.")
      }
    })
    
    # Display the total number of files
    output$total_files <- renderText({
      paste("Total Files: ", length(files_in_folder))
      })
    
    
    
    
    
    
    # List only .xlsx files for plotting
    files_in_folder_xlsx <- list.files(file_path, pattern = "\\.xlsx$", full.names = TRUE)
    # Explicitly remove any files starting with ~$
    files_in_folder_xlsx <- files_in_folder_xlsx[!grepl("^~\\$", basename(files_in_folder_xlsx))]
    
    # If no .xlsx files, display message in UI
    if (length(files_in_folder_xlsx) == 0) {
      output$data_plot <- renderUI({
        h4("No .xlsx files found to plot.")
      })
      return(NULL)  # Return early if no .xlsx files to plot
    }
    
    
    # Load all datasets from .xlsx files and create individual plots
    all_data <- lapply(files_in_folder_xlsx, function(filepath) {
      # Read the Excel file, find the row where 'Date' and 'Time' are present, and start reading from there
      person <- read_excel(filepath)
      
      # Find the row number where "Date" and "Time" are located
      header_row <- which(person[, 1] == "Date" & person[, 2] == "Time")
      
      
      # Read the file again, skipping all rows before the header_row
      person <- read_excel(filepath, skip = header_row)%>%
        na.omit() |>
        mutate(datetime = ymd_hms(paste(Date, Time)),
               Value = as.numeric(Value))
      
      return(person)
    })
    
    # Remove any NULL elements (files that couldn't be read)
    all_data <- Filter(Negate(is.null), all_data)
    
    # Dynamically create individual plots for all datasets
    output$data_plot <- renderUI({
      if (length(all_data) == 0) {
        return(h4("No valid data available to plot."))
      }
      
      plot_list <- lapply(1:length(all_data), function(i) {
        plot_data <- all_data[[i]]
        
        # Create individual plot for each dataset
        plot_output <- renderPlot({
          ggplot(plot_data, aes(x = datetime, y = Value)) +
            geom_line() +
            labs(title = paste("Dataset", i), x = "Datetime", y = "Value") +
            theme_minimal()
        })
        
        # Create a plot output UI element for each plot
        plotOutput(outputId = paste0("plot_", i), height = "300px")
      })
      
      # Return the list of plots
      do.call(tagList, plot_list)
    })
    
    # Render individual plots for each dataset
    lapply(1:length(all_data), function(i) {
      output[[paste0("plot_", i)]] <- renderPlot({
        plot_data <- all_data[[i]]
        ggplot(plot_data, aes(x = datetime, y = Value)) +
          geom_line() +
          labs(title = paste("Dataset", i), x = "Datetime", y = "Value") +
          theme_minimal()
      })
    })
  })
}