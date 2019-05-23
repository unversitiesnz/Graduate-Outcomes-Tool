# Disclaimer Page
disclaimerUi <- unz.layout(pageName='disclaimer',
  div( #class="container",
    
    uiOutput("mdOutput")
  
  )
)

disclaimerServer <- shinyServer(function(input, output, session) {
  output$mdOutput <- renderUI({
    includeMarkdown(file.path("./md", "disclaimer.Rmd")) 
  })
  
})