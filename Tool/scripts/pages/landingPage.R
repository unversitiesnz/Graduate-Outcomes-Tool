
landingUi <- unz.layout(pageName = 'about',
  div( #class="container",
    
    div(
      class="row jumbotron",
      div( class="col-md-7",
        h1("Graduate Outcomes Online Tool"),
        p(class="lead", "Track the outcomes for graduates from the New Zealand tertiary sector, for up to six years after graduation")
      ),
      div(
        class="hidden-xs hidden-sm col-md-5",
        tags$img(class="birds",src="img/universities-birds.svg")
      )
    ),
    div(
      div(class="col-md-12", 
          h2("About the tool"),
          p("The Graduate Outcomes Tool (the Tool), developed by Universities New Zealand (UNZ), presents the economic and employment outcomes of tertiary graduates who completed studies between 2009 and 2015, and follows their outcomes for up to 6 years following the completion of their studies."),
          p(
            "The Graduate Outcomes Tool was developed using the ", 
            tags$a(
              "Integrated Data Infrastructure  (IDI).", 
              href="http://archive.stats.govt.nz/browse_for_stats/snapshots-of-nz/integrated-data-infrastructure.aspx", 
              target="_blank"
            ), 
            "Monthly indicators on the economic outcomes of graduates are constructed to present a dynamic story about the transition and outcomes of graduates. The Tool sets out the outcomes of domestic graduates by ethnicity, gender, level of study, subsector (university or non-university graduates) and",
            tags$a(
              "broad field", 
              href="https://www.educationcounts.govt.nz/data-services/collecting-information/code-sets-and-classifications/new_zealand_standard_classification_of_education_nzsced", 
              target="_blank"
            ), 
            "of completed study. Outcomes for typical young or mature domestic graduates  can be analysed separately, while outcomes for international graduates are grouped only by level of study, subsector and broad field of study."
          ),
          p("This report accompanies the release of the Tool, explains the methodology and business rules applied in developing it and provides a high-level summary of the main findings for a selected subgroup of graduates as an illustration of how it can be used."),
          p("As our collective understanding of graduate outcomes increases, the quality of data improves and its coverage extends—and with feedback from users on the indicators and functionality of the Tool-UNZ intends to continue refining indicators, extending the follow-up timeframe and contributing to evidence on the socio-economic outcomes of tertiary graduates."),
          h2("Background"),
          
          p("To observe the long-term outcomes of graduates, we focus on three consecutive cohorts  of graduates, those who completed their studies in 2009, 2010 and 2011. Their outcomes can be fully observed for up to 6 years. The number of graduates in each cohort, when grouped by demographics and the characteristics of completed degrees, is not large enough to construct statistically meaningful indicators by field of study. Therefore, we constructed indicators for combined cohorts,  to enable users to analyse outcomes by broadly defined fields of study."),
          p("We make a clear distinction between university graduates, non-university graduates, domestic graduates and international students, young and mature graduates. We also present the outcomes of graduate cohorts from 2012 to 2015 to enable a comparison between the outcomes of more recent cohorts with those of earlier cohorts. The most recent cohort is graduates from 2015 and most of their outcomes can be observed for up to two years, until the end of 2017."),
          p("For each cohort of graduates, two distinct subgroups are identified: university and non-university graduates. This is done mainly to allow us to compare the outcomes of graduates from university sector with those from the rest of tertiary sector."),
          p("Furthermore, we make a clear distinction between domestic and international graduates. The pathways and outcomes of these groups should be analysed separately. For domestic students, users can select specific demographic subgroups: by gender, prioritised ethnicity, field of study and the characteristics of completed degrees."),
          p("Users also can separate outcomes for typical young graduates or mature graduates. For international graduates, information can be analysed only by the characteristics of completed degrees and field of study. Comparative cohort analysis can be done on multiple cohorts at the same time across all indicators. This is to allow users to compare and monitor the outcomes of recent cohorts with earlier cohorts. We also allow users to combine multiple cohorts and compare multiple indicators on the same graph."),
          p("This interactive tool also enables users to observe trends in those returning to tertiary education. It will be useful in helping understand graduate outcomes and developing government and sectoral policies to support transition from tertiary education into the work force, and policies to encourage a return to tertiary education."),
          p("For more details see the", tags$a("accompanying report", href="2018_A4_report_accompany_tool_v14_FINAL.pdf", target="_blank"))

      ),
      div(class="col-md-6 hidden", 
          h2("Monthly Indicators") ,
          p("Have a look at what graduates get upto in the first five years after graduation."),
          tags$a(class="btn btn-lg btn-default", href="#!/monthlyIndicators", "Monthly Indicators")
      
      ),
      div(class="col-md-6 hidden", 
          h2("Recent Indicators") ,
          p("Have a look at how some cohorts are doing which have not yet had five years after graduation, possible future development."),
          tags$a(class="btn btn-lg btn-default", href="", "Recent Indicators")
          
      )
      
      
      
      
    )
    
  )
)

landingServer <- shinyServer(function(input, output, session) {
 
  
})