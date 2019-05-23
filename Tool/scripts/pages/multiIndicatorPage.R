
############ chart module: ################

multiIndicatorChartUI <- function(id) {
  ns <- NS(id)
  div( class = "col-lg-6 col-md-12",
       
       tags$br(),
       # let the user select which indicator to chart
       selectInput(ns("indicator"), "Indicator", indicatorOptions.dom, selected=1, multiple = TRUE),
       div(
         # the chart
         column(12,d3Output(ns("distPlot"), height = 600)),
         
         # notes regarding the chart
         featureControl(feature.suppression_notes,div(class="text",textOutput(ns("outputNotes")))),
         featureControl(feature.aggregation_notes,div(class="text", textOutput(ns("aggregationNotes"))))
         
         # let the user download the data behind the chart
         
       )
  )
}
# Server for indicator D3 Chart Module
multiIndicatorChart <- function(input, output, session, filters, indicatorSet, reactiveData, incomeOnly = 0, defaultIndicator = "Overseas") {
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
      currentIndicator <- defaultIndicator
    } else if (!currentIndicator %in% indicatorSet()) {
      # if the indicator is no longer in indicater set (e.g. on domestic, select Job Seekers then change to international)
      currentIndicator <- defaultIndicator
    }
    print(currentIndicator)
    updateSelectInput(session, "indicator", choices = indicatorSet(), selected = currentIndicator)
    
    #}
    
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
    data <- reactiveData()$data
    validate(
      need(nrow(data) >0, "There is no data to display for the selected filters.")
    )
    selectedData <- data
    # selectedData <- reactSelectedData()$data
    
    
    if (incomeOnly == 1) {
      incomeMeasureEncoding <- list(  "Earnings from wages or salary (mean)" = "wns_income_mean",
                                      "Earnings from wages or salary (median)" = "wns_income_median")
      titles <- incomeMeasureEncoding[input$indicator]
    } else {
      # print(indicatorsSelected)
      indicatorsSelected <- indicator_names.v2[input$indicator]
      dataLines <- indicatorsSelected
      num_titles <- paste(dataLines, "num", sep="_")
      denom_titles <- paste(dataLines, "denom", sep="_")
      prop_titles <- paste(dataLines, "prop", sep="_")
      
      temp <- selectedData[num_titles] / selectedData[denom_titles]
      
      temp[(temp > 1) & !is.na(temp)] <- 1 # work around for issue to do with low counts
      
      selectedData[prop_titles] <- temp
      titles <- prop_titles
    }
    
    
    #selectedData$prop_data <- selectedData$overseas_num / selectedData$overseas_denom
    
    if (!is.null(selectedData)) {
      print("attempting to run d3 script")
      
      r2d3(
        list(d = selectedData, indicator = input$indicator, lineNames = unname(titles), multiLine = 1, yLabel="", stackKey = 1, incomeOnly = incomeOnly),
        script = file.path("./www/multiline_chart.js"),
        css = file.path("./www/css/percentage_chart.css")
      )
      
    }
    else
      "Check filter selection"
    # present message?
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

############ end chart module! ############


getMultiIndicatorUi <- function(pageName) {
  unz.layout(pageName = pageName,
             div(
               # Sidebar
               sidebarLayout(
                 div(class = "col-xs-12 well" #"col-md-3 col-sm-4 well"
                     ,
                     tags$form(class="form",
                               # h4("Cohort Filters"),
                               div(class="col-sm-4",
                                   selectInput("cohort", "Cohort", multiCohortOptions, selected = multiCohortOptions[1], multiple = TRUE),
                                   bsTooltip("cohort", "Select to include in aggregations", placement = "top"),
                                   selectInput("domestic", "Domestic Status", domesticOptions, selected = 1),
                                   bsTooltip("domestic", "Domestic fee paying? or International?", placement = "top")
                               )
                               ,
                               
                               # conditionalPanel(
                               #  condition = "input.domestic == 'TRUE'",
                               div(class="col-sm-4",
                                   selectInput("sex", "Sex", sexOptions, selected = -1),
                                   selectInput("ethnicity", "Ethnicity", ethnicityOptions, selected = -1, multiple = TRUE)
                               )
                               # )
                               ,
                               div(class="col-sm-4",
                                   selectInput("youngGrad", "Young or Mature graduate", youngGradOptions, selected = -1),
                                   selectInput("studyLevel", "Level of Study", studyLevelOptions, selected = -1, multiple = TRUE),
                                   bsTooltip("studyLevel", "The level at which the graduate graduated.", placement = "top")
                               )
                     )
                     
                 ),
                 
                 # Output area
                 div(class= "col-xs-12" #"col-md-9 col-sm-7"
                     ,
                     div(class="row",
                         tableOutput("testTable")
                         
                     ),
                     
                     div(class="row",
                         multiIndicatorChartUI("chart1"),
                         multiIndicatorChartUI("chart2")),
                     
                     textOutput("testOutput")
                     #tableOutput("ageProfile"),
                     #tableOutput("fieldOfStudyProfile")
                     , downloadButton("download", "Download data")
                     
                 )
                 
               )
             )
             
  )
}
getMultiIndicatorServer <- function(subsector) {
  # Define server logic required to draw a histogram
  multiIndicatorServer <- function(input, output, session) {
    setObservableAll(input, session, "ethnicity")
    setObservableAll(input, session, "studyLevel")
    
    selectedFilters <- reactive({
      print("filter call")
      list(domestic = as.numeric(input$domestic) 
           , sex = as.numeric(input$sex)
           , ethnicity = as.numeric(input$ethnicity)
           , cohort = as.numeric(input$cohort)
           , subsector = subsector
           , fieldOfStudy = NA
           , young_grad = as.numeric(input$youngGrad)
           , studyLevel = as.numeric(input$studyLevel))
    })
    aggregationApplied <- reactive({
      appliedFilters <- selectedFilters()
      applied <- ((length(appliedFilters$ethnicity) > 1 || -1 == appliedFilters$ethnicity) ||
                    (length(appliedFilters$studyLevel) > 1 || -1 == appliedFilters$studyLevel) ||
                    -1 == appliedFilters$sex ||
                    -1 == appliedFilters$young_grad ||
                    -1 == appliedFilters$domestic
      )
      if (is.na(applied)) {
        return(FALSE)
      } else {
        return (applied)
      }
    })
    
    indicatorSet <- reactive({
      #validate(need(input$domestic == TRUE | input$domestic == FALSE, "must have domestic value in order for this to run"))
      if (is.null(input$domestic)) {
        indicatorOptions.prop.int
      }
      else if(input$domestic == 1) {
        indicatorOptions.prop.dom
      } else { indicatorOptions.prop.int}
    })
    
    indicatorIncomeSet <- reactive({
      if (aggregationApplied()) {
        indicatorOptions.income[indicatorOptions.income != "Earnings from wages or salary (median)"]
      } else {
        indicatorOptions.income
      }
    })
    
    filterSetData <- reactive({
      print("Data retrived")
      getCube.filterAndAggregateByOptions.v2(selectedFilters())
    })
    
    output$testTable <- renderTable({
      #filterSetData()$data
    })
    
    #print(indicatorSet())
    callModule(multiIndicatorChart, "chart1", selectedFilters, indicatorSet, filterSetData)
    callModule(multiIndicatorChart, "chart2", selectedFilters, indicatorIncomeSet, filterSetData, incomeOnly = 1, defaultIndicator = indicatorIncomeSet())
    
    observe({
      shinyjs::toggleState("sex", input$domestic == 1)
      shinyjs::toggleState("ethnicity", input$domestic == 1)
      shinyjs::toggleState("youngGrad", input$domestic == 1)
    })
    
    output$download <- downloadHandler(
      filename = function() {
        paste("dataset", ".xlsx", sep = "")
      },
      content = function(file) {
        #write.csv(filterSetData()$data, file, row.names = FALSE, na="S")
        # http://www.sthda.com/english/wiki/r-xlsx-package-a-quick-start-guide-to-manipulate-excel-files-in-r
        # TODO: write a better download
        
        #indicator <- indicatorSet()[1]
        selectedData <- filterSetData()$data
        wb<-createWorkbook(type="xlsx")
        addDisclaimer(wb)
        addFilterSheet(wb, selectedFilters())
        addSheetsForIndicators(wb, indicatorSet(), selectedData)
        
        saveWorkbook(wb, file)
        
      }
    )
  }
}