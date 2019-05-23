library(dplyr)

getCube.dataset1.dom.select <- function(indicator.data, optionSet) {
  #print(anyNA(optionSet$eth))
  return ( (indicator.data$sex %in% optionSet$sex | -1 %in% optionSet$sex) &
            indicator.data$domestic %in% optionSet$dom &
            indicator.data$cohort %in% optionSet$cohort &
            (indicator.data$ter_com_subsector %in% optionSet$subsector | -1 %in% optionSet$subsector)  &
            ((indicator.data$ethnicity %in% optionSet$eth) | -1 %in% optionSet$eth) &
            indicator.data$dataset == "dataset1" &
            (indicator.data$ter_com_qual_type %in% optionSet$studyLevel | -1 %in% optionSet$studyLevel) &
             (indicator.data$young_grad %in% optionSet$young_grad | -1 %in% optionSet$young_grad)
            )
}
getCube.dataset1.int.select <- function(indicator.data, optionSet) {
  return ((indicator.data$domestic == optionSet$dom | -1 %in% optionSet$dom) &
            indicator.data$cohort %in% optionSet$cohort &
            (indicator.data$ter_com_subsector %in% optionSet$subsector | -1 %in% optionSet$subsector) &
            indicator.data$dataset == "dataset1" &
            (indicator.data$ter_com_qual_type %in% optionSet$studyLevel | -1 %in% optionSet$studyLevel))
}
getCube.dataset2.dom.select <- function(indicator.data, optionSet) {
  return (indicator.data$domestic == optionSet$dom &
            (indicator.data$sex %in% optionSet$sex | -1 %in% optionSet$sex) &
            (indicator.data$ethnicity %in% optionSet$eth | -1 %in% optionSet$eth)  &
            (indicator.data$ter_com_subsector %in% optionSet$subsector | -1 %in% optionSet$subsector) &
            (indicator.data$ter_com_NZSCED %in% optionSet$fieldOfStudy | -1 %in% optionSet$fieldOfStudy) &
            indicator.data$dataset == "dataset2" &
            (indicator.data$ter_com_qual_type %in% optionSet$studyLevel | -1 %in% optionSet$studyLevel) &
            (indicator.data$young_grad %in% optionSet$young_grad | -1 %in% optionSet$young_grad))
}
getCube.dataset2.int.select <-function(indicator.data, optionSet) {
  return ((indicator.data$domestic == optionSet$dom | -1 %in% optionSet$dom) &

            (indicator.data$ter_com_subsector %in% optionSet$subsector | -1 %in% optionSet$subsector) &
            (indicator.data$ter_com_NZSCED %in% optionSet$fieldOfStudy | -1 %in% optionSet$fieldOfStudy) &
            indicator.data$dataset == "dataset2" &
            (indicator.data$ter_com_qual_type %in% optionSet$studyLevel | -1 %in% optionSet$studyLevel))
}

getCube.selector <-function(optionSet) {
  if(anyNA(optionSet$cohort)) {
    datasetName <- "dataset2"
  } else {
    datasetName <- "dataset1"
  }
  return (switch(datasetName,
         "dataset1" = switch(as.character(optionSet$dom), "1" = getCube.dataset1.dom.select, "0" = getCube.dataset1.int.select, "-1" = getCube.dataset1.int.select),
         "dataset2" = switch(as.character(optionSet$dom), "1" = getCube.dataset2.dom.select, "0" = getCube.dataset2.int.select, "-1" = getCube.dataset2.int.select)))
  #getCube.dataset1.dom.select
}

getCube.forIndicator <- function(optionSet) {
  print("!!!!Deprecated (getCube.forIndicator)!!!!!!")
  print("Unsable? Will be removed?")
  warning("This function might break!")
  optionSet$indicator.v2 <- indicator_names.v2[[optionSet$indicator]]
  if (optionSet$indicator.v2 == 'wns_income') {
    temp <- subset(datacube.v2,
                   select = c('domestic', 'ter_com_subsector', 'young_grad', 'sex', 'ethnicity', 'ter_com_qual_type', 'ter_com_NZSCED', 'month', 'dataset', 'cohort',
                              paste(optionSet$indicator.v2, 'num', sep='_'),
                              paste(optionSet$indicator.v2, 'denom', sep='_'),
                              paste(optionSet$indicator.v2, 'mean', sep='_'),
                              paste(optionSet$indicator.v2, 'median', sep='_')))
    names(temp)[names(temp) == paste(optionSet$indicator.v2, 'num', sep='_')] <- 'num'
    names(temp)[names(temp) == paste(optionSet$indicator.v2, 'denom', sep='_')] <- 'denom'
    names(temp)[names(temp) == paste(optionSet$indicator.v2, 'mean', sep='_')] <- 'mean'
    names(temp)[names(temp) == paste(optionSet$indicator.v2, 'median', sep='_')] <- 'median'
    return (temp)
  } else {
    temp <- subset(datacube.v2, select = c('domestic', 'ter_com_subsector', 'young_grad', 'sex', 'ethnicity', 'ter_com_qual_type', 'ter_com_NZSCED', 'month', 'dataset', 'cohort', paste(optionSet$indicator.v2, 'num', sep='_'), paste(optionSet$indicator.v2, 'denom', sep='_')))
    names(temp)[names(temp) == paste(optionSet$indicator.v2, 'num', sep='_')] <- 'num'
    names(temp)[names(temp) == paste(optionSet$indicator.v2, 'denom', sep='_')] <- 'denom'
    return (temp)
  }
}

#' Get the dataset based on the options passed to it.
#'
#' @param optionSet A list/vector with the following fields: list(dom = bool, sex = int, eth = int, studyLevel = int, subsector = string, fieldOfStudy = int, cohort = int, indicator = string).
#' @return The data rows that relate to optionsSet.
#' @examples
#' getCube.filteredByOptions(optionSet)
getCube.filteredByOptions <- function(optionSet) {
  filterFunction <- getCube.selector(optionSet)
  indicator.data <- getCube.forIndicator(optionSet)
  indicator.data[filterFunction(indicator.data, optionSet),]
}

getCube.filteredByOptions.v2 <- function(optionSet) {
  filterFunction <- getCube.selector(optionSet)
  print(paste("selecting this meany rows:", sum(filterFunction(datacube.v2, optionSet))))
  #indicator.data <- getCube.forIndicator(optionSet)
  datacube.v2[filterFunction(datacube.v2, optionSet),]
}

getCube.aggregate <- function(filtered.data, optionSet) {
  if (optionSet$indicator == indicator_names$wns_mean) {
    filtered.data %>%
      filter(!is.na(mean)) %>%
      group_by(month) %>%
      summarise(base_num = sum(num), weighted_value =  weighted.mean(mean, num))
  } else if (optionSet$indicator == indicator_names$wns_median) {
    filtered.data %>%
      filter(!is.na(median)) %>%
      group_by(month) %>%
      summarise(base_num = sum(num), weighted_value =  weighted.mean(median, num))
  } else {
    aggregate(x = filtered.data[,c("num", "denom")], by = list(month = filtered.data$month), FUN=sum, na.rm = TRUE)
  }
}

getCube.aggregate.cohort <- function(filtered.data, optionSet) {
  if (optionSet$indicator == indicator_names$wns_mean) {
    filtered.data %>%
      filter(!is.na(mean)) %>%
      group_by(month, cohort) %>%
      summarise(base_num = sum(num), weighted_value =  weighted.mean(mean, num))
  } else if (optionSet$indicator == indicator_names$wns_median) {
    filtered.data %>%
      filter(!is.na(median)) %>%
      group_by(month, cohort) %>%
      summarise(base_num = sum(num), weighted_value =  weighted.mean(median, num))
  } else {
    aggregate(x = filtered.data[,c("num", "denom")], by = list(month = filtered.data$month, cohort = filtered.data$cohort), FUN=sum, na.rm = TRUE)
  }
}

# given the data, indicate weather suppression has been applied, and if aggregation is required.
checkCube.about <- function(data, optionSet) {
  return (list(
    hasData = (
      nrow(data) > 0
    ),
    suppression = (
      (
        optionSet$indicator %in% c(indicator_names$overseas, indicator_names$all_benefit, indicator_names$job_seeker_benefit, indicator_names$enrolled_university, indicator_names$enrolled_higher_university, indicator_names$enrolled_tertiary_study, indicator_names$employed, indicator_names$employed_wns, indicator_names$neet) &&
        anyNA(data$num)
      ) ||
      (
        optionSet$indicator %in% c(indicator_names$employer_change, indicator_names$regional_mobility, indicator_names$district_mobility) &&
        anyNA(data[-c(0), "num"])
      ) ||
      (
        optionSet$indicator == indicator_names$wns_mean &&
          anyNA(data[, "mean"])
      )
    ),
    aggregation = (nrow(data) > 73),
    multiCohort = !is.null(optionSet$multiCohort) && optionSet$multiCohort
  ))
}
getCube.filterAndAggregateByOptions <- function(optionSet) {
  filteredData <- getCube.filteredByOptions(optionSet)
  #decide if suppression was applied here?
  #return as list(data=data, containsSuppression=True/False)
  about <- checkCube.about(filteredData, optionSet)
  if (about$hasData) {
    if(about$multiCohort) {
      aggregatedData <- getCube.aggregate.cohort(filteredData, optionSet)
    } else {
      aggregatedData <- getCube.aggregate(filteredData, optionSet)
    }

    return (list(data=aggregatedData, about=about))
  } else {
    return (list(data=filteredData, about=about))
  }
}
getCube.aggregate.v2 <- function(filtered.data, optionSet) {
  #indicator_names.v2
  proportionIndicators <- unique(indicator_names.v2)
  num_titles <- paste(proportionIndicators, "num", sep="_")
  denom_titles <- paste(proportionIndicators, "denom", sep="_")
  titles <- append(num_titles, denom_titles)
  # titles <- distinct(titles)
  if (!is.null(optionSet$dimCohort) && optionSet$dimCohort) {
    proportionData <- aggregate(x = filtered.data[,titles], by = list(month = filtered.data$month, cohort = filtered.data$cohort), FUN=sum, na.rm = TRUE)

    incomeData <- filtered.data %>%
      filter(!is.na(wns_income_mean)) %>%
      group_by(month, cohort) %>%
      summarise(wns_income_mean = weighted.mean(wns_income_mean, wns_income_num), wns_income_median = weighted.mean(wns_income_median, wns_income_num))
  } else {
    proportionData <- aggregate(x = filtered.data[,titles], by = list(month = filtered.data$month), FUN=sum, na.rm = TRUE)
    #print(filtered.data$wns_income_mean)
    incomeData <- filtered.data %>%
      filter(!is.na(wns_income_mean)) %>%
      group_by(month) %>%
      summarise(wns_income_mean = weighted.mean(wns_income_mean, wns_income_num), wns_income_median = weighted.mean(wns_income_median, wns_income_num))
  }
  return (merge(proportionData, incomeData))
}
getCube.filterAndAggregateByOptions.v2 <- function(optionSet) {
  filteredData <- getCube.filteredByOptions.v2(optionSet)

  filteredData2 <- getCube.aggregate.v2(filteredData, optionSet)
  #decide if suppression was applied here?
  #return as list(data=data, containsSuppression=True/False)
  #about <- checkCube.about(filteredData, optionSet)
  return (list(data=filteredData2, about=NULL))
}
