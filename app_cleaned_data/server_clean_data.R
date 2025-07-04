server <- function(input, output, session) {
    
    
    # Reactive subset of data based on selected UID
    filtered_data <- reactive({
        req(input$uid_select)
        data_clean_unclean[data_clean_unclean$uid.x == input$uid_select, ]
    })
    
    
    # Output the date range
    output$date_range <- renderText({
        df <- filtered_data()
        paste("Date range:", 
              format(min(df$datetime.x, na.rm = TRUE)), " to ",
              format(max(df$datetime.x, na.rm = TRUE)), "  --  Legend: blue = unclean, red = clean")
    })
    
    ## Plot comparison or something meaningful
    output$comparison_plot <- renderPlot({
        df <- filtered_data()  
        
        plot1 <- ggplot(df, aes(x = datetime.x)) +
            geom_point(aes(y = IBH_TEMP.y), color = "blue") +
            geom_point(aes(y = IBH_TEMP.x), color = "brown2") +
            ggtitle("IBH_TEMP") + labs(x="Time", y="°C") +
            ylim(c(15,45)) + theme(
                plot.margin = margin(10, 10, 30, 30),
                axis.title.x = element_text(margin = margin(t = 10)),
                axis.title.y = element_text(margin = margin(r = 10)),
                axis.text.x = element_text(size = 10),
                axis.text.y = element_text(size = 10)
            )
        
        plot2 <- ggplot(df, aes(x = datetime.x)) +
            geom_point(aes(y = IBH_HUM.y), color = "blue") +
            geom_point(aes(y = IBH_HUM.x), color = "brown2") +
            ggtitle("IBH_HUM") + labs(x="Time", y="%") +
            ylim(c(0,100)) + theme(
                plot.margin = margin(10, 10, 30, 30),
                axis.title.x = element_text(margin = margin(t = 10)),
                axis.title.y = element_text(margin = margin(r = 10)),
                axis.text.x = element_text(size = 10),
                axis.text.y = element_text(size = 10)
            )
        
        plot3 <- ggplot(df, aes(x = datetime.x)) +
            geom_point(aes(y = IBW_TEMP.y), color = "blue") +
            geom_point(aes(y = IBW_TEMP.x), color = "brown2") +
            ggtitle("IBW_TEMP") + labs(x="Time", y="°C") +
            ylim(c(15,45)) + theme(
                plot.margin = margin(10, 10, 30, 30),
                axis.title.x = element_text(margin = margin(t = 10)),
                axis.title.y = element_text(margin = margin(r = 10)),
                axis.text.x = element_text(size = 10),
                axis.text.y = element_text(size = 10)
            )
        
        plot4 <- ggplot(df, aes(x = datetime.x)) +
            geom_point(aes(y = IBW_HUM.y), color = "blue") +
            geom_point(aes(y = IBW_HUM.x), color = "brown2") +
            ggtitle("IBW_HUM") + labs(x="Time", y="%") +
            ylim(c(0,100)) + theme(plot.margin = margin(10, 10, 30, 30))
        
        plot5 <- ggplot(df, aes(x = datetime.x)) +
            geom_point(aes(y = IBT_TEMP.y), color = "blue") +
            geom_point(aes(y = IBT_TEMP.x), color = "brown2") +
            ggtitle("IBT_TEMP") + labs(x="Time", y="°C") +
            ylim(c(15,45)) + theme(
                plot.margin = margin(10, 10, 30, 30),
                axis.title.x = element_text(margin = margin(t = 10)),
                axis.title.y = element_text(margin = margin(r = 10)),
                axis.text.x = element_text(size = 10),
                axis.text.y = element_text(size = 10)
            )
        
        gridExtra::grid.arrange(plot1, plot2, plot3, plot4, plot5, ncol = 1)
    })
}