#indicatorDecriptions = read.csv("indicatorIndex.csv", row.names = 1)
#row.names(indicatorDecriptions)[indicatorDecriptions$ShownInInternational == "TRUE"]

indicatorChartUI <- function(id) {
    ns <- NS(id)
    div(
      div( class = "col-lg-6 col-md-12",
          tags$br(),
          selectInput(ns("indicator"), "Indicator", indicatorOptions.dom, selected=1),
          div(
          h2(textOutput(ns("indicatorTitle"))),
          textOutput(ns("indicatorDescription") #, class="indicator-description"
                     ),
          column(12,plotOutput(ns("distPlot"))),
          textOutput(ns("outputNotes")),
          downloadButton(ns("download"), "Download csv")
          )
      )
    )
}

indicatorChart <- function(input, output, session, filters, indicatorSet) {
  observe({
    req(indicatorSet)
    #if (input$indicator %in% indicatorSet()) {
    #   preValue <- input$indicator
    #    updateSelectInput(session, "indicator", choices = indicatorSet(), selected = which(indicatorSet() == preValue))
    # } else {
    updateSelectInput(session, "indicator", choices = indicatorSet())
    #}
    
  })  
  
  observe({
    indValue <<- input$indicator
  })
  reactSelectedData <- reactive({
    selectedFilters = filters()
      validate(
        need(selectedFilters$ethnicity | is.na(selectedFilters$ethnicity), "Ethnicity filter is missing - please check that you have selected"),
        need(selectedFilters$studyLevel | is.na(selectedFilters$studyLevel), "Level of Study filter is missing - please check that you have selected"),
        need(selectedFilters$fieldOfStudy | is.na(selectedFilters$fieldOfStudy), "Field of Study filter is missing - please check that you have selected")
      )
      print("chart - selectedFilters")
      #print(req(selectedFilters$ethnicity))
      getData(selectedFilters, input$indicator)
   })
    
    output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      
      selectedData <- reactSelectedData()
      if (!is.null(selectedData))
        if (input$indicator %in% list("W&S Income (Mean)", "W&S Income (Median)")) {
          ggplot(data=selectedData, aes(x=month, y=weighted_value)) +
            geom_smooth(colour="#4CC0E0", size = 1, method = 'loess', formula = 'y ~ x') +
            geom_line(colour="#4D6D8C", size= 1) + #+ labs(title = "Title","Months", "percentage")
            
            #scale_y_continuous(breaks=c(0,0.25,0.5,0.75,1),labels=c("0%", "25%","50%","75%","100%")) +
            scale_y_continuous(breaks=c(1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000),labels=c("$1,000", "$2,000", "$3,000", "$4,000", "$5,000", "$6,000", "$7,000", "$8,000", "$9,000", "$10,000", "$11,000"), limits = c(1000, 12000)) +
            scale_x_continuous(breaks=c(0,12,24,36,48,60, 72),labels=c("Qual completion","1 year", "2 years","3 years","4 years","5 years", "6 years")) +
            xlab("years post graduation") +
            ylab(input$indicator) +
            
            theme_classic() +
            theme(axis.text=element_text(size=12, colour="#404040"),
                  #plot.background=element_rect(colour="#CAC3BD"),
                  axis.title=element_text(size=14,face="bold", colour = "#298098"),
                  panel.grid.major=element_line(size = 0.5, colour="#4CC0E0", linetype = "dotted")
            )
        } else {
          #print(as.numeric(Sys.time())*1000, digits=15)
          ggplot(data=selectedData, aes(x=month, y=prop)) +
          geom_smooth(colour="#4CC0E0", size = 1, method = 'loess', formula = 'y ~ x') +
            geom_line(colour="#4D6D8C", size= 1) + #+ labs(title = "Title","Months", "percentage")
            
            #scale_y_continuous(breaks=c(0,0.25,0.5,0.75,1),labels=c("0%", "25%","50%","75%","100%")) +
            scale_y_continuous(breaks=c(0,0.1,0.2,0.3,0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1),labels=c("0%", "10%","20%","30%","40%", "50%", "60%", "70%", "80%", "90%", "100%"), limits = c(0, 1)) +
            scale_x_continuous(breaks=c(0,12,24,36,48,60, 72),labels=c("Qual completion","1 year", "2 years","3 years","4 years","5 years", "6 years")) +
            xlab("years post graduation") +
            ylab("percentage") +
            
            theme_classic() +
            theme(axis.text=element_text(size=12, colour="#404040"),
                  #plot.background=element_rect(colour="#CAC3BD"),
                  axis.title=element_text(size=14,face="bold", colour = "#298098"),
                  panel.grid.major=element_line(size = 0.5, colour="#4CC0E0", linetype = "dotted")
            )
          #print(as.numeric(Sys.time())*1000, digits=15)
          #thePlot
        }
      else
        "Check filter selection"
        # present message?
   })

   output$outputNotes <- renderText({
     if (input$indicator %in% list("W&S Income (Mean)", "W&S Income (Median)")) {
       if (any(is.na(reactSelectedData()[,"weighted_value"])))
       {
         "NOTE: contains suppressed values"
       } else if (is.null(reactSelectedData())) {
         warning(paste0("Data is missing:"))
         "ERROR: Data is missing"
       }
     } else {
       if (any(is.na(reactSelectedData()[,"prop"])))
       {
         "NOTE: contains suppressed values"
       } else if (is.null(reactSelectedData())) {
         warning(paste0("Data is missing:"))
         "ERROR: Data is missing"
       }
     }
   })
   
   output$indicatorTitle <- renderText({
     paste("Indicator:", input$indicator)
   })
   output$indicatorDescription <- renderText({
     "Indicator text: a bit of text explaining how the indicator was created, and what the chart is showing."
     paste(indicatorDecriptions[input$indicator, "description"])
   })
   
   output$download <- downloadHandler(
     filename = function() {
       paste("dataset", ".csv", sep = "")
     },
     content = function(file) {
       write.csv(reactSelectedData(), file, row.names = FALSE, na="S")
     }
   )
}