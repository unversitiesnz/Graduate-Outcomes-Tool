
# Define UI for application that draws a histogram
# monthly views: 


if (feature.disable_dataset2) {
   cohortOptions <- c(2009, 2010, 2011)
}

getIndicatorUi <- function(pageName) {
indicatorUi <- unz.layout(pageName = pageName,
   div(
   # Sidebar
   sidebarLayout(
      div(class = "col-xs-12 well",
          tags$form(class="form",
            # h4("Cohort Filters"),
            div(class="col-sm-4",
             
             selectInput("domestic", "Domestic Status", domesticOptions, selected = 1),
             bsTooltip("domestic", "Domestic fee paying? or International?", placement = "top"),
             selectInput("sex", "Sex", sexOptions, selected = -1)
            ),
           div(class="col-sm-4",
             
             selectInput("ethnicity", "Ethnicity", ethnicityOptions, selected = -1, multiple = TRUE),
             selectInput("youngGrad", "Young or Mature graduate", youngGradOptions, selected = -1)
           )
               
             ,
             div(class="col-sm-4",
                
                selectInput("studyLevel", "Level of Study", studyLevelOptions, selected = -1, multiple = TRUE),
                bsTooltip("studyLevel", "The level at which the graduate graduated.", placement = "top"),
                featureControl(!feature.disable_dataset2,   selectInput("fieldOfStudy", "Field of Study", fieldOfStudyOptions, selected=-1, multiple = TRUE))
             )
          )
      ),
      
      # Output area
      div(class= "col-xs-12" #"col-md-9 col-sm-7"
          ,
      
        div(class="row",
        indicatorD3ChartUI("chart1"),
        indicatorD3ChartUI("chart2")),
        div(class="row",indicatorD3ChartUI("chart3"),
        indicatorD3ChartUI("chart4")),
        
        textOutput("testOutput"),
        downloadButton("download", "Download data")
        #tableOutput("ageProfile"),
        #tableOutput("fieldOfStudyProfile")
         
      )
   )
   )
)
}

getIndicatorServer <- function(subsector) {
   return (

# Define server logic
function(input, output, session) {
   # what to do when all and other options are selected?
   
   setObservableAll(input, session, "ethnicity")
   obs1 <- setObservableAll(input, session, "studyLevel")
   setObservableAll(input, session, "fieldOfStudy")
   
   selectedFilters <- reactive({
     print("filter call")
      print(subsector)
     list(domestic = as.numeric(input$domestic) 
                                     , sex = as.numeric(input$sex)
                                    , young_grad = as.numeric(input$youngGrad)
                                     , ethnicity = as.numeric(input$ethnicity)
                                     , cohort = NA
                                     , subsector = subsector
                                     , fieldOfStudy = as.numeric(input$fieldOfStudy)
                                     , studyLevel = as.numeric(input$studyLevel))
     })
   aggregationApplied <- reactive({
      appliedFilters <- selectedFilters()
      applied <- ((length(appliedFilters$ethnicity) > 1 || -1 == appliedFilters$ethnicity) ||
                     (length(appliedFilters$studyLevel) > 1 || -1 == appliedFilters$studyLevel) ||
                     -1 == appliedFilters$sex ||
                     -1 == appliedFilters$young_grad || 
                     -1 == appliedFilters$domestic ||
                     (-1 == appliedFilters$fieldOfStudy || length(appliedFilters$fieldOfStudy) > 1)
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
      result <- getCube.filterAndAggregateByOptions.v2(selectedFilters())
      print(result)
      result
   })
   #print(indicatorSet())
   callModule(indicatorD3Chart, "chart1", selectedFilters, indicatorSet, filterSetData)
   callModule(indicatorD3Chart, "chart2", selectedFilters, indicatorSet, filterSetData)
   callModule(indicatorD3Chart, "chart3", selectedFilters, indicatorSet, filterSetData)
   callModule(indicatorD3Chart, "chart4", selectedFilters, indicatorSet, filterSetData)
   observe({
     #shinyjs::toggleState("fieldOfStudy", input$cohort == "NA")
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
         
         addSheetsForIndicators(wb, indicatorSet(), selectedData)
         saveWorkbook(wb, file)
      }
   )
})
}