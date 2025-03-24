# server logic
server <- function(input, output, session) {  
  
  # filter the redcap data for starttimes within the selected date range
  filtered_data <- reactive({
    
    req(input$date_range)  # get range
    
    data_filtered <- redcap |>
      filter(as.Date(starttime) >= input$date_range[1] &        # filter by range
               as.Date(starttime) <= input$date_range[2]) |>
      dplyr::mutate(starttime = format(starttime, "%Y-%m-%d %H:%M:%S"),
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
    
    
    # for plotting list only .xlsx files ENVIRONMENTAL FILES
    files_in_folder_xlsx <- list.files(file_path, pattern = "\\.xlsx$", full.names = TRUE)
    # explicitly remove any files starting with ~$ (temporary excel files)
    files_in_folder_xlsx <- files_in_folder_xlsx[!grepl("^~\\$", basename(files_in_folder_xlsx))]
    
    # for plotting list only .xls files NOISE FILE
    files_in_folder_xls <- list.files(file_path, pattern = "\\.xls$", full.names = TRUE)
    # explicitly remove any files starting with ~$ (temporary excel files)
    files_in_folder_xls <- files_in_folder_xls[!grepl("^~\\$", basename(files_in_folder_xls))]
    
    
    

    
    # get starttime and endtime from redcap for the selected ui-event-pair
    participant <- reactive({
      
      req(input$uid_select) 
      req(input$date_range)
      
      participant_data <- redcap |>
        filter(as.Date(starttime) >= input$date_range[1] & 
                 as.Date(starttime) <= input$date_range[2]) |>
        filter(uid == input$uid_select) |>
        dplyr::mutate(starttime = format(starttime, "%Y-%m-%d %H:%M:%S"),
               endtime = format(endtime, "%Y-%m-%d %H:%M:%S")) 
      
      return(participant_data)
    })
    
    
    
    # if there are no .xlsx files, display message in UI and stop the code
    if (length(files_in_folder_xlsx) == 0) {
      output$data_plot <- renderUI({
        h4("No .xlsx files found to plot.")
      })
      return(NULL)  # stop here..
    }
    
    
    
    # load all datasets from .xlsx files and create individual plots
    all_data_xlsx <- lapply(files_in_folder_xlsx, function(filepath) {
      
      # Read the Excel file
      person <- read_excel(filepath)
      
      # find the row number where "Date" and "Time" are located
      header_row <- which(person[, 1] == "Date" & person[, 2] == "Time")
      
      # read the file again, skipping all rows before the header_row and delete NAs
      person <- read_excel(filepath, skip = header_row) |>
        na.omit() |>
        dplyr::mutate(datetime = ymd_hms(paste(Date, Time)),
               Value = as.numeric(Value)) 
      
      # ensure `participant()` has data before filtering
      req(nrow(participant()) > 0)
      
      # extract start and end times
      start_time <- as.POSIXct(participant()$starttime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
      end_time <- as.POSIXct(participant()$endtime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
      
      # Filter environmental data based on `participant()` start & end times
      person <- person |>
        filter(datetime >= start_time & datetime <= end_time)
      
      return(person)
    })
    
    
    
    
    # Load all datasets from .xls files (noise)
    all_data_xls <- lapply(files_in_folder_xls, function(filepath) {
      
      # Ensure you are using an actual file from the directory
      if (length(files_in_folder_xls) > 0) {
        file_to_read <- files_in_folder_xls  # Pick the first .csv file
        person <- read.delim(file_to_read, skip = 2, header = TRUE)
      } else {
        stop("No .csv files found in the directory.")
      }
      
      colnames(person) <- c("datetime", "LEQ_dB_A")
      
      person <- person |>
        select(datetime, LEQ_dB_A) |>
        na.omit() |>
        dplyr::mutate(datetime = ymd_hms(datetime),
               Value = as.numeric(LEQ_dB_A)) |>
        select(-LEQ_dB_A)
    
    
    # Ensure `participant()` has data before filtering
    req(nrow(participant()) > 0)
    
    # Extract start and end times
    start_time <- as.POSIXct(participant()$starttime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
    end_time <- as.POSIXct(participant()$endtime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
    
    # Filter noise data based on participant() start & end times
    person <- person |>
      filter(datetime >= start_time & datetime <= end_time)
    
      return(person)
    })
    
    
    
    
    # Combine environmental and noise data
    all_data <- c(all_data_xlsx, all_data_xls)
    
    
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
    files_in_folder_xlxs_unique <- c(sub(common_prefix_path, "", files_in_folder_xlsx), sub(common_prefix_path, "", files_in_folder_xls))
    
    # colors for plotting
    cols = c("skyblue2", "brown1", "brown1","skyblue2", "brown1", "grey1")
    
    # yaxis lims
    ytempmax = max(all_data[[5]]$Value, na.rm = TRUE) + 2
    ytempmin = min(all_data[[5]]$Value, na.rm = TRUE) - 2
    
    y1 <- rep(c(0, ytempmin, ytempmin, 0, ytempmin, 30), length.out = length(all_data))
    y2 <- rep(c(100, ytempmax, ytempmax, 100, ytempmax, 100), length.out = length(all_data))
    
    
    # render individual plots for each dataset
    lapply(1:length(all_data), function(i) {
      
      # render the plot
      output[[paste0("plot_", i)]] <- renderPlot({
        plot_data <- all_data[[i]]
        
        # asign title
        title <- substr(files_in_folder_xlxs_unique[i], 0,18)
        
        # customize plot
        ggplot(plot_data, aes(x = datetime, y = Value)) +
          geom_line(color = cols[i], linewidth = 1.1) +
          labs(title = title, x = "time", y = "") +
          scale_x_datetime(date_labels = "%b %d", date_breaks = "24 hour") +
          scale_y_continuous(limits = c(y1[i], y2[i])) + 
          theme_minimal()
      })
    })
  })
  
  
  
  
  
  
  output$download_pdf <- downloadHandler(
    filename = function() {
      paste0("Weekly_Report_", Sys.Date(), ".pdf")
    },
    
    content = function(file) {
      pdf(file)
      
      # Define participant data *before* the loop, without `reactive()`
      participant_data <- redcap |>
        filter(as.Date(starttime) >= input$date_range[1] &
                 as.Date(starttime) <= input$date_range[2]) |>
        mutate(starttime = format(starttime, "%Y-%m-%d %H:%M:%S"),
               endtime = format(endtime, "%Y-%m-%d %H:%M:%S"))
      
      tryCatch({
        
        # Loop through all unique UIDs to generate individual PDFs
        unique_uids <- unique(filtered_data()$uid)
        
        for (uid in unique_uids) {
          print(paste("Processing UID:", uid))
          
          # Filter data for this UID
          filtered_data_selected <- filtered_data() |> filter(uid == uid)
          redcap_event <- filtered_data_selected |> pull(redcap_event_name)
          
          # Construct file path
          file_path <- paste0("~/SynologyDrive/Participants/", uid, "/",
                              gsub("_", "", redcap_event), "/")
          
          # List only .xlsx files (Environmental Data)
          files_in_folder_xlsx <- list.files(file_path, pattern = "\\.xlsx$", full.names = TRUE)
          files_in_folder_xlsx <- files_in_folder_xlsx[!grepl("^~\\$", basename(files_in_folder_xlsx))]
          
          # List only .xls files (Noise Data)
          files_in_folder_xls <- list.files(file_path, pattern = "\\.xls$", full.names = TRUE)
          files_in_folder_xls <- files_in_folder_xls[!grepl("^~\\$", basename(files_in_folder_xls))]
          
          # Filter participant data *inside the loop*, without using `reactive()`
          participant <- participant_data |> filter(uid == uid)
          
          # Loop through Environmental Files
          if (length(files_in_folder_xlsx) > 0) {
            for (i in files_in_folder_xlsx) {
              person <- read_excel(i)
              
              # Locate header row
              header_row <- which(person[, 1] == "Date" & person[, 2] == "Time")
              
              # Read file with correct header row
              person <- read_excel(i, skip = header_row) |> 
                na.omit() |> 
                mutate(datetime = ymd_hms(paste(Date, Time)),
                       Value = as.numeric(Value))
              
              # Get start_time and end_time from participant
              start_time <- as.POSIXct(participant$starttime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
              end_time <- as.POSIXct(participant$endtime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
              
              # Filter data based on time range
              person <- person |> filter(datetime >= start_time & datetime <= end_time)
              
              # Generate environmental plot
              plot1 <- ggplot(person, aes(x = datetime, y = Value)) +
                geom_line(linewidth = 1.1) +
                labs(title = paste("Environmental Data for", basename(i)), x = "Time", y = "Value") +
                scale_x_datetime(date_labels = "%b %d", date_breaks = "24 hour") +
                theme_minimal()
              
              print(plot1)  # Ensure ggplot gets printed to the PDF
            }
          }
          
          # Noise Data Plotting
          if (length(files_in_folder_xls) > 0) {
            for (file_to_read in files_in_folder_xls) {  # Use `for` loop here for clarity, even if we just take the first file
              person <- read.delim(file_to_read, skip = 2, header = TRUE)
              colnames(person) <- c("datetime", "LEQ_dB_A")
              
              person <- person |> 
                select(datetime, LEQ_dB_A) |> 
                na.omit() |> 
                mutate(datetime = ymd_hms(datetime),
                       Value = as.numeric(LEQ_dB_A)) |> 
                select(-LEQ_dB_A)
              
              start_time <- as.POSIXct(participant$starttime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
              end_time <- as.POSIXct(participant$endtime[1], format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
              
              # Filter noise data
              person <- person |> filter(datetime >= start_time & datetime <= end_time)
              
              # Generate noise plot
              plot2 <- ggplot(person, aes(x = datetime, y = Value)) +
                geom_line(linewidth = 1.1) +
                labs(title = paste("Noise Data for", basename(file_to_read)), x = "Time", y = "Value") +
                scale_x_datetime(date_labels = "%b %d", date_breaks = "24 hour") +
                theme_minimal()
              
              print(plot2)  # Ensure ggplot gets printed to the PDF
            }
          }
        }
        
      }, error = function(e) {
        message("Error while generating plots:", e$message)
      }, finally = {
        dev.off()  # Always close the PDF device
      })
    }
  )
}
