#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
source("global.R")
library(shiny)

router <- make_router(
  route("about", landingUi, landingServer),
  route("combined-cohorts-by-field-of-study-university", getIndicatorUi("combined cohorts - university"), getIndicatorServer("University")),
  route("combined-cohorts-by-field-of-study-non-university", getIndicatorUi("combined cohorts - non-university"), getIndicatorServer("non-University")),
  route("cohort-comparison-university", getMultiLineUi("cohort compare - university"), getMultilineServer("University")),
  route("cohort-comparison-non-university", getMultiLineUi("cohort compare - non-university"), getMultilineServer("non-University")),
  route("indicator-comparison-university", getMultiIndicatorUi("indicator compare - university"), getMultiIndicatorServer("University")),
  route("indicator-comparison-non-university", getMultiIndicatorUi("indicator compare - non-university"), getMultiIndicatorServer("non-University")),
  route("disclaimer", disclaimerUi, disclaimerServer)
)
ui <- shinyUI(fluidPage(
  tags$head(tags$link(rel="shortcut icon", href="favicon.ico")),
  router_ui()
))
server <- shinyServer(function(input, output, session) {
  router(input, output, session)
})
# Run the application 

shinyApp(ui = ui, server = server)