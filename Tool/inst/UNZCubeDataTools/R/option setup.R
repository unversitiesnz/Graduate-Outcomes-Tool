# set options

domesticOptions = list("ALL" = -1,"Domestic"=1, "International"=0)

sexOptions = list("ALL" = -1, "Male" = 1, "Female" = 2)
# macron issue! https://github.com/tidyverse/tibble/issues/87 & https://github.com/tidyverse/dplyr/issues/1950
ethnicityOptions = list("ALL" = -1, "European"=1, "M\u101ori"=2, "Pasifika"=3, "Asian"=4, "Other"=5)
studyLevelOptions = list("ALL" = -1, "Level 1-4 Certificates" = 1,
"Certificates and Diploma Level 5-7" = 2,
"Bachelor Degrees" = 3,
"Honours, postgrad dipl" = 4,
"Masters degrees" = 5,
"Doctoral degrees" = 6
)
youngGradOptions <- list(
  "ALL" = -1,
  "Young Graduate" = 1,
  "Mature Graduate" = 0
)
fieldOfStudyOptions = list("ALL" = -1,
  "01 Natural and Physical Sciences" = 1,
  "02 Information Technology" = 2,
  "03 Engineering and Related Technologies" = 3,
  "04 Architecture and Building" = 4,
  "05 Agriculture, Environmental and Related Studies" = 5,
  "06 Health" = 6,
  "07 Education" = 7,
  "08 Management and Commerce" = 8,
  "09 Society and Culture" = 9,
  "10 Creative Arts" = 10,
  "11 Food, Hospitality and Personal Services" = 11,
  "12 Mixed Field Programmes" = 12
)

subsectorOptions = list("All" = -1, "University", "non-University")

cohortOptions = list("All" = -1,"2009" = 2009, "2010" = 2010, "2011" = 2011)


sexToId <- function(sex) {
  switch (sex,
    "Male" = 1, "Female" = 2
  )
}
domesticToId <- function(domestic) {
  switch (domestic,
          "Domestic" = 1, "International" = 0
  )
}
ethnicityToId <- function(ethnicity) {
  switch (ethnicity,
          "European" = 1, "M\u101ori" = 2, "Pasifika" = 3, "Asian" = 4, "Middle Eastern/Latin American/African" = 5, "Other" = 6
  )
}

optionSetToString <- function(optionSet) {
  paste("domestic:", optionSet$dom,
        ", sex:", optionSet$sex,
        ", eth:", optionSet$eth,
        ", studyLevel:", optionSet$studyLevel,
        ", subsector:", optionSet$subsector,
        ", fieldOfStudy:", optionSet$fieldOfStudy,
        ", cohort:", optionSet$cohort,
        ", indicator:", optionSet$indicator, collapse = '|')
}
