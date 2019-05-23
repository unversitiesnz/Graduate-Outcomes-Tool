library(shiny)
#library(shinyjs)
unz_header <- function() {
  
  div(
    
    id = "unz-header", class="navbar-branding-header",
    
    div(class = "unz-topbar"),
    
    div(
      
      class = "unz-brand",
      
      tags$a(class = "unz-brand", href = "https://www.universitiesnz.ac.nz/",
             
             title = "Universities NZ",
             div(id="unz-logo",
               tags$img(src = "img/universities-logo.svg",
                        
                        alt = "Universities NZ"))
             ),
      div(id = "menu-line", class="hidden"),
      div(id = "site-menu-title", class="hidden", tags$a(class="navbar-brand", href="/", "Graduate Outcomes Online Tool"))
      
    )
  )
}

unz.bootstrap.header <- function() {
  div( class="navbar navbar-default",
       div( class="container-fluid",
    div(
      class = "navbar-header",
      #nav branding
      unz_header(),
      tags$button(
        type = "button", class="navbar-toggle", `data-toggle`="collapse", `data-target`=".left-menu",
        span(
          id="menu-expand", class="glyphicon glyphicon-list"
        ),
        span(
          id="menu-close", class="glyphicon glyphicon-remove", style="display: none;"
        ),
        tags$br(),
        span(
          id="menu-toggle-button-title", "MENU"
        )
      )
      
    )
    
       )
  )
}

unz.layout <- shinyUI(function(this.body, pageName = "") { bootstrapPage(
  title = "Graduate outcomes online tool",
  tags$head( tagList(
    includeScript("gtm-head.js"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/main.css"),
    tags$meta(charset="UTF-8"),
    tags$link(rel="shortcut icon", href="favicon.ico"),
    useShinyjs()
  )),
  tags$noscript(
    tags$iframe(
      src="https://www.googletagmanager.com/ns.html?id=GTM-PCWGN8G",
      height="0", width="0", style="display:none;visibility:hidden"
    )
  ),
  div(class="",
    unz.bootstrap.header(),
    div(class="row",
      div(class="col-sm-3",
        tags$ul(class="collapse navbar-collapse left-menu",
          tags$li(class=ifelse(pageName == "about", "active", ""),
            tags$a(href="#!/about","About")
          ),
          tags$li(
            tags$a(href="2018_A4_report_accompany_tool_v14_FINAL.pdf","Accompanying report", target="_blank")
          ),
          tags$li(class="category",
            "Combined cohorts by field of study"
          ),
          tags$li(class=paste(ifelse(pageName == "combined cohorts - university", "active", ""), "subitem"),
            tags$a(href="#!/combined-cohorts-by-field-of-study-university","University graduates")
          ),
          tags$li(class=paste(ifelse(pageName == "combined cohorts - non-university", "active", ""), "subitem"),
            tags$a(href="#!/combined-cohorts-by-field-of-study-non-university","Non University graduates")
          ),
          tags$li(class="category",
            "Cohort comparison"
          ),
         tags$li(class=paste(ifelse(pageName == "cohort compare - university", "active", ""), "subitem"),
           tags$a(href="#!/cohort-comparison-university","University graduates")
         ),
         tags$li(class=paste(ifelse(pageName == "cohort compare - non-university", "active", ""), "subitem"),
           tags$a(href="#!/cohort-comparison-non-university","Non University graduates")
         ),
         tags$li(class="category",
                 "Indicator comparison"
         ),
          tags$li(class=paste(ifelse(pageName == "indicator compare - university", "active", ""), "subitem"),
            tags$a(href="#!/indicator-comparison-university","University graduates")
          ),
         tags$li(class=paste(ifelse(pageName == "indicator compare - non-university", "active", ""), "subitem"),
           tags$a(href="#!/indicator-comparison-non-university","Non University graduates")
         ),
          tags$li(class=ifelse(pageName == "disclaimer", "active", ""),
            tags$a(href="#!/disclaimer","Disclaimer")
          ),
         tags$li(
           tags$a(href="https://github.com/unversitiesnz/Graduate-Outcomes-Tool", "Link to source codes", target="_blank")
         )
        )
      ),
      div(class="col-sm-9",
        this.body
      )
    ),
    tags$footer(class="footer",
      p(HTML("&copy; 2019 - Universities New Zealand - Te P&#333;kai Tara"))
    )
  )
)
})
