# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Title
    titlePanel("Uncleaned / Cleaned Data Screening"),
    
    # Sidebar layout
    sidebarLayout(
        sidebarPanel(
            # Dropdown for selecting UID
            selectInput("uid_select", 
                        "Select Participant for Plotting:", 
                        choices = unique(data_clean$uid),  
                        selected = unique(data_clean$uid)[1])
        ),  
        
        # Main panel displaying filtered data and plots
        mainPanel(
            textOutput("date_range"),
            plotOutput("comparison_plot", height = "1200px", width = "100%")
        )
    )
)