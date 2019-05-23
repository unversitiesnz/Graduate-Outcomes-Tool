getAgeProfileData <- function() {
  data.frame(age.group = c("15 - 17", "18 - 20", "21 - 25", "25 - 35"), age.count = c(12,14,15,56))
}

getFieldOfStudyProfileData <- function() {
  data.frame(
    field.of.study = c(
      "01 Natural and Physical Sciences", 
      "02 Information Technology", 
      "03 Engineering and Related Technologies", 
      "04 Architecture and Building",
      "05 Agriculture, Environmental and Related Studies",
      "06 Health",
      "07 Education",
      "08 Management and Commerce",
      "09 Society and Culture",
      "10 Creative Arts",
      "11 Food, Hospitality and Personal Services",
      "12 Mixed Field Programmes"
      ), 
    field.count = c(12,14,15,56,34,54,43,4,23,43,55,11))
}

getNationOriginProfileData <- function() {
  data.frame(
    nation = c(
      "USA", "UK"
    ),
    nation.count = c(
      12, 24
    )
  )
}