
multiCohortOptions <- list(2009, 2010, 2011, 2012, 2013, 2014, 2015)

# recent cohort ######################################
getMultiLineUi <- function(pageName) {
multiLineUi <- unz.layout(pageName = pageName,
  div(
    # Sidebar
    sidebarLayout(
      div(class = "col-xs-12 well" #"col-md-3 col-sm-4 well"
          ,
          tags$form(class="form",
                    # h4("Cohort Filters"),
                    div(class="col-sm-4",
                        selectInput("cohort", "Cohort", multiCohortOptions, selected = multiCohortOptions[1], multiple = TRUE),
                        bsTooltip("cohort", "Select more than one cohort to compare", placement = "top"),
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
              indicatorD3MultilineUI("chart1"),
              indicatorD3MultilineUI("chart2")),
          div(class="row",indicatorD3MultilineUI("chart3"),
              indicatorD3MultilineUI("chart4")),
          
          textOutput("testOutput"),
          downloadButton("download", "Download data")
      )
    )
  )
  
)
}
getMultilineServer <- function(subsector) {
  return (
# Define server
multilineServer <- function(input, output, session) {
  setObservableAll(input, session, "ethnicity")
  setObservableAll(input, session, "studyLevel")

  selectedFilters <- reactive({
    print("filter call")
    list(domestic = as.numeric(input$domestic) 
         , young_grad = as.numeric(input$youngGrad)
         , sex = as.numeric(input$sex)
         , ethnicity = as.numeric(input$ethnicity)
         , cohort = as.numeric(input$cohort)
         , subsector = subsector
         , fieldOfStudy = NA
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
  indicatorSet <- indicatorOptionsReative(input, aggregationApplied)
  
  filterSetData <- reactive({
    print("Data retrived")
    filters <- selectedFilters()
    filters$dimCohort <- TRUE
    getCube.filterAndAggregateByOptions.v2(filters)
  })
  
  #print(indicatorSet())
  callModule(indicatorD3Multiline, "chart1", selectedFilters, indicatorSet, filterSetData)
  callModule(indicatorD3Multiline, "chart2", selectedFilters, indicatorSet, filterSetData)
  callModule(indicatorD3Multiline, "chart3", selectedFilters, indicatorSet, filterSetData)
  callModule(indicatorD3Multiline, "chart4", selectedFilters, indicatorSet, filterSetData)
  observe({
    shinyjs::toggleState("sex", input$domestic == 1)
    shinyjs::toggleState("ethnicity", input$domestic == 1)
    shinyjs::toggleState("youngGrad", input$domestic == 1)
  })
  
  #observeEvent(input$navibar,{
  # if(input$navibar == "home"){
  #  browseURL("https://www.google.com")
  #}
  #})
  
  output$download <- downloadHandler(
    filename = function() {
      paste("dataset", ".xlsx", sep = "")
    },
    content = function(file) {
      selectedData <- filterSetData()$data
      wb<-createWorkbook(type="xlsx")
      addDisclaimer(wb)
      addFilterSheet(wb, selectedFilters())
      addSheetsForIndicators(wb, indicatorSet(), selectedData, c("month", "cohort"))
      saveWorkbook(wb, file)
    }
  )
})
### END RECNET COHORT;
}