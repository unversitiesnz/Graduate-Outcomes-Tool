# UI for indicator D3 Chart Module
indicatorD3MultilineUI <- function(id) {
  ns <- NS(id)
  div( class = "col-lg-6 col-md-12",
       
       tags$br(),
       # let the user select which indicator to chart
       selectInput(ns("indicator"), "Indicator", indicatorOptions.dom, selected=1),
       div(
        # h2(textOutput(ns("indicatorTitle"))),
         div( class="indicator-description text",textOutput(ns("indicatorDescription"))),
         
         # the chart
         column(12,d3Output(ns("distPlot"))),
         
         # notes regarding the chart
         featureControl(feature.suppression_notes,div(class="text",textOutput(ns("outputNotes")))),
         featureControl(feature.aggregation_notes,div(class="text", textOutput(ns("aggregationNotes"))))
       )
  )
}
# Server for indicator D3 Chart Module
indicatorD3Multiline <- function(input, output, session, filters, indicatorSet, dataset) {
  # save a reference to the environment of the module
  moduleEvn <- environment()
  
  # save the currently selected indicator
  observe({
    # saves the value into the module's environment
    assign(session$ns("ind_value"),input$indicator, envir = moduleEvn) 
  })
  
  # read the currently selected indicator
  observe({
    req(indicatorSet)
    
    currentIndicator <- get(session$ns("ind_value"), envir = moduleEvn)
    if (is.null(currentIndicator)) {
      # indicator is likely to be null on first run
      currentIndicator <- "Overseas"
    } else if (!currentIndicator %in% indicatorSet()) {
      # if the indicator is no longer in indicater set (e.g. on domestic, select Job Seekers then change to international)
      currentIndicator <- "Overseas"
    }
    print(currentIndicator)
    updateSelectInput(session, "indicator", choices = indicatorSet(), selected = currentIndicator)
    
  }) 
  
  output$distPlot <- renderD3({
    selectedFilters = filters()
    validate(
      need(selectedFilters$cohort, "Cohort filter is missing - please check that you have selected"),
      need( (selectedFilters$ethnicity) || 1 != selectedFilters$domestic, "Ethnicity filter is missing - please check that you have selected"),
      need(selectedFilters$studyLevel, "Level of Study filter is missing - please check that you have selected"),
      need(
        !(
          input$indicator == "Earnings from wages or salary (median)" && 
            (
              (length(selectedFilters$ethnicity) > 1 || -1 == selectedFilters$ethnicity) ||
                (length(selectedFilters$studyLevel) > 1 || -1 == selectedFilters$studyLevel) ||
                -1 == selectedFilters$sex
            )
          
        ), "W&S Income (Median) is disabled for 'All' options (expect cohort), and when more than one option is selected in any of the filters. This is because we do not currently have a statistically valid way to produce these outputs with the data we have.")
    )
    data <- dataset()$data
    validate(
      need(nrow(data) >0, "There is no data to display for the selected filters.")
    )
    selectedData <- getDataForIndicatorOrMagnitude(input$indicator, data, c("month", "cohort"))
    
    if (input$indicator %in% c(indicator_names$wns_mean, indicator_names$wns_median) ) {
      #if (input$indicator == indicator_names$wns_mean) {
        # why
        colnames(selectedData) <- c("month", "cohort", "weighted_value")
      #}
      selectedData <- tidyr::spread(selectedData, cohort, weighted_value)
    } else {
      selectedData$num <- NULL
      selectedData$denom <- NULL
      selectedData <- tidyr::spread(selectedData, cohort, prop)
    }
    
    if (!is.null(selectedData)) {
      #print("attempting to run d3 script")
      
        r2d3(
          list(d = selectedData, indicator = input$indicator, lineNames = filters()$cohort, multiLine = 1, stackKey = 0),
          script = file.path("./www/multiline_chart.js"),
          css = file.path("./www/css/percentage_chart.css")
        )
      
    }
    else
      "Check filter selection"
    # present message?
  })
  
  output$outputNotes <- renderText({
      if (reactSelectedData()$about$suppression)
      {
        "NOTE: contains suppressed values, suppressed values are removed from calculations and aggregations"
      }
  })
  
  output$aggregationNotes <- renderText({
    if (reactSelectedData()$about$aggregation)
    {
      if (input$indicator == "W&S Income (Mean)") {
        "The values have been aggregated using weighted means"
      } else {
        "NOTE: the values have been aggregated by summing paired denominators and numerators"
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
  
}