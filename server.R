# server logic
server <- function(input, output, session) {  
  
  # filter the redcap data for starttimes within the selected date range
  filtered_data <- reactive({
    
    req(input$date_range)  # get range
    
    data_filtered <- redcap %>%
      filter(as.Date(starttime) >= input$date_range[1] &        # filter by range
               as.Date(starttime) <= input$date_range[2]) %>%
      mutate(starttime = format(starttime, "%Y-%m-%d %H:%M:%S"),
             endtime = format(endtime, "%Y-%m-%d %H:%M:%S")) 
    
    # give all uid with starttime within the range for selection for plots
    updateSelectInput(session, "uid_select", 
                      choices = unique(data_filtered$uid),  # only unique uids
                      selected = unique(data_filtered$uid)[1])  
    return(data_filtered)
  })
  
  
  
  # show the filtered data
  output$filtered_data <- renderTable({
    filtered_data() 
  }, rownames = TRUE)
  
  
  # generate the file path based on the selected uid and the event which happened in the date range
  # the same person cannot be observed twice in the same week!
  observeEvent(input$uid_select, {
    
    # get selected uid
    selected_uid <- input$uid_select
    
    # get the corresponding redcap_event_name for the selected UID
    redcap_event <- filtered_data() |>
      filter(uid == selected_uid) |>
      pull(redcap_event_name)
    
    # create the file path based on UID and redcap_event_name to the data to be plotted
    file_path <- paste0("~/SynologyDrive/Participants/", selected_uid, "/", 
                        gsub("_", "", redcap_event)
                        , "/")
    
    # output the file path to the UI
    output$file_path <- renderText({
      paste("File Path: ", file_path)
    })
    
    
    
    # list files in the folder and remove common prefixes
    files_in_folder <- list.files(file_path, full.names = TRUE)  # List files in the directory
    #     find the common prefix in the file paths
    common_prefix_path <- common_prefix(files_in_folder)
    #     remove the common prefix from each file path
    files_in_folder_unique <- sub(common_prefix_path, "", files_in_folder)
    
    
    # display the list of files
    output$file_list_ui <- renderUI({
      if (length(files_in_folder) > 0) {
        # if there are files, display them in a list
        tagList(
          h4("Files in Folder:"),
          tags$ul(lapply(files_in_folder_unique, function(file) {
            tags$li(file)  # Create list items with the unique part of the file paths
          }))
        )
      } else {
        # if no files, display a message
        h4("No files found in this folder.")
      }
    })
    
    
    
    # display the total number of files
    output$total_files <- renderText({
      paste("Total Files: ", length(files_in_folder))
      })
    
    
    
    
    # for plotting list only .xlsx files
    files_in_folder_xlsx <- list.files(file_path, pattern = "\\.xlsx$", full.names = TRUE)
    # explicitly remove any files starting with ~$ (temporary excel files)
    files_in_folder_xlsx <- files_in_folder_xlsx[!grepl("^~\\$", basename(files_in_folder_xlsx))]
    
    
    
    # get starttime and endtime from redcap for the selected ui-event-pair
    participant <- reactive({
      
      req(input$uid_select) 
      req(input$date_range)
      
      participant <- redcap %>%
        filter(as.Date(starttime) >= input$date_range[1] & 
                 as.Date(starttime) <= input$date_range[2]) %>%
        filter(uid == input$uid_select) |>
        mutate(starttime = format(starttime, "%Y-%m-%d %H:%M:%S"),
               endtime = format(endtime, "%Y-%m-%d %H:%M:%S")) 
      
      return(participant)
    })
    
    
    
    # if there are no .xlsx files, display message in UI and stop the code
    if (length(files_in_folder_xlsx) == 0) {
      output$data_plot <- renderUI({
        h4("No .xlsx files found to plot.")
      })
      return(NULL)  # stop here..
    }
    
    
    
    # load all datasets from .xlsx files and create individual plots
    all_data <- lapply(files_in_folder_xlsx, function(filepath) {
      
      # Read the Excel file
      person <- read_excel(filepath)
      
      # find the row number where "Date" and "Time" are located
      header_row <- which(person[, 1] == "Date" & person[, 2] == "Time")
      
      # read the file again, skipping all rows before the header_row and delete NAs
      person <- read_excel(filepath, skip = header_row) %>%
        na.omit() %>%
        mutate(datetime = ymd_hms(paste(Date, Time)),
               Value = as.numeric(Value)) 
      
      # ensure `participant()` has data before filtering
      req(nrow(participant()) > 0)
      
      # extract start and end times
      start_time <- as.POSIXct(participant()$starttime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
      end_time <- as.POSIXct(participant()$endtime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
      
      # Filter environmental data based on `participant()` start & end times
      person <- person %>%
        filter(datetime >= start_time & datetime <= end_time)
      
      return(person)
    })
    
    
    
    # remove any NULL elements (files that couldn't be read)
    all_data <- Filter(Negate(is.null), all_data)
    
    
    
    # dynamically create individual plots for all datasets
    output$data_plot <- renderUI({
      if (length(all_data) == 0) {
        return(h4("No valid data available to plot."))
      }
      
      # loop through the data thats to be plotted
      plot_list <- lapply(1:length(all_data), function(i) {
        
        plot_data <- all_data[[i]]
        
        # create individual plot for each dataset
        plot_output <- renderPlot({
          
          ggplot(plot_data, aes(x = datetime, y = Value)) +
            geom_line() +
            labs(title = paste("Dataset", i), x = "Datetime", y = "Value") +
            theme_minimal()
        })
        
        # Create a plot output UI element for each plot
        plotOutput(outputId = paste0("plot_", i), height = "200px", width = "600px")
      })
      
      # Return the list of plots
      do.call(tagList, plot_list)
    })
    
    
    # for title of plots: find the common prefix in the xlxs file paths
    common_prefix_path_xlxs <- common_prefix(files_in_folder_xlsx)
    # remove the common prefix from each file path to get filenames
    files_in_folder_xlxs_unique <- sub(common_prefix_path, "", files_in_folder_xlsx)
    
    # colors for plotting
    cols = c("skyblue2", "brown1", "brown1","skyblue2", "brown1")
    
    
    
    # render individual plots for each dataset
    lapply(1:length(all_data), function(i) {
      
      # render the plot
      output[[paste0("plot_", i)]] <- renderPlot({
        plot_data <- all_data[[i]]
        
        # asign title
        title <- substr(files_in_folder_xlxs_unique[i], 0,18)
        
        # customize plot
        ggplot(plot_data, aes(x = datetime, y = Value)) +
          geom_line(color = cols[i], size = 1.2) +
          labs(title = title, x = "time", y = "") +
          scale_x_datetime(date_labels = "%b %d", date_breaks = "24 hour") +
          theme_minimal()
      })
    })
  })
}

