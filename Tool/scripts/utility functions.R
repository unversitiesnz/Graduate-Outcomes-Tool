xlsx.addTitle<-function(sheet, rowIndex, title, titleStyle){
  rows <-createRow(sheet,rowIndex=rowIndex)
  sheetTitle <-createCell(rows, colIndex=1)
  setCellValue(sheetTitle[[1,1]], title)
  setCellStyle(sheetTitle[[1,1]], titleStyle)
}

addDisclaimer <- function(wb) {
  
  TITLE_STYLE <- CellStyle(wb)+ Font(wb,  heightInPoints=16, 
                                     color="#4d6d8c", isBold=TRUE)
  
  DisclaimerStyle <- CellStyle(wb) + Font(wb, isBold=FALSE, heightInPoints=14) +
    Alignment(wrapText=TRUE)
  
  disclaimerSheet <- createSheet(wb, sheetName = "Disclaimer")
  xlsx.addTitle(disclaimerSheet, rowIndex=1, title="Disclaimer",
                titleStyle = TITLE_STYLE)
  xlsx.addTitle(disclaimerSheet, rowIndex=2, 
                title="The results in this report are not official statistics, they have been created for research purposes from the Integrated Data Infrastructure (IDI), managed by Statistics New Zealand. The opinions, findings, recommendations, and conclusions expressed in this report are those of the author(s), not Statistics NZ or Universities NZ.",
                titleStyle = DisclaimerStyle)
  xlsx.addTitle(disclaimerSheet, rowIndex=3, 
                title="Access to the anonymised data used in this study was provided by Statistics NZ in accordance with security and confidentiality provisions of the Statistics Act 1975. Only people authorised by the Statistics Act 1975 are allowed to see data about a particular person, household, business, or organisation, and the results in this report have been confidentialised to protect these groups from identification. Careful consideration has been given to the privacy, security, and confidentiality issues associated with using administrative and survey data in the IDI. Further detail can be found in the Privacy impact assessment for the Integrated Data Infrastructure available from www.stats.govt.nz.",
                titleStyle = DisclaimerStyle)
  xlsx.addTitle(disclaimerSheet, rowIndex=4, 
                title="The results are based in part on tax data supplied by Inland Revenue to Statistics NZ under the Tax Administration Act 1994. This tax data must be used only for statistical purposes, and no individual information may be published or disclosed in any other form, or provided to Inland Revenue for administrative or regulatory purposes. Any person who has had access to the unit record data has certified that they have been shown, have read, and have understood section 81 of the Tax Administration Act 1994, which relates to secrecy. Any discussion of data limitations or weaknesses is in the context of using the IDI for statistical purposes, and is not related to the data’s ability to support Inland Revenue’s core operational requirements.",
                titleStyle = DisclaimerStyle)
  
  
  setColumnWidth(disclaimerSheet, colIndex=1, colWidth=120)
}

getDataForIndicator.v2 <- function(dataLines, selectedData, dims = c("month")) {
  if (nrow(selectedData) == 0) {
    stop("data invalid - 0 rows have been supplied.")
  }
  num_titles <- paste(dataLines, "num", sep="_")
  denom_titles <- paste(dataLines, "denom", sep="_")
  prop_titles <- paste(dataLines, "prop", sep="_")
  temp <- selectedData[num_titles] / selectedData[denom_titles]
  temp[(temp > 1) & !is.na(temp),] <- 1 # work around for issue to do with low counts
  
  selectedData[prop_titles] <- temp
  d <- selectedData[c(dims, num_titles, denom_titles, prop_titles)]
  colnames(d) <- c(dims, "num", "denom", "prop")
  return(d)
}

getDataForIndicatorOrMagnitude <- function(indicator, selectedData, dims = c("month")) {
  indicatorsSelected <- indicator_names.v2[indicator]
  if (indicatorsSelected == 'wns_income') {
    if (indicator == indicator_names$employed_wns) {
      indData <- getDataForIndicator.v2(indicatorsSelected, selectedData, dims)
    } else if (indicator == indicator_names$wns_mean) {
      indicator <- "Mean Earnings (W&S)"
      indData <- selectedData[c(dims, "wns_income_mean")]
    } else if (indicator == indicator_names$wns_median) {
      indicator <- "Median Earnings (W&S)"
      indData <- selectedData[c(dims, "wns_income_median")]
    }
  } else {
    indData <- getDataForIndicator.v2(indicatorsSelected, selectedData, dims)
  }
  return (indData)
  # return(indData)
}

fitIndicatorNameToSheet <- function(name) {
  if (name == indicator_names$wns_mean) {
    return("Mean Earnings (W&S)")
  } else if (name == indicator_names$wns_median) {
    return("Median Earnings (W&S)")
  } else {
    return(name)
  }
}

addFilterSheet <- function(wb, filters) {
  TITLE_STYLE <- CellStyle(wb)+ Font(wb,  heightInPoints=16, 
                                     color="#4d6d8c", isBold=TRUE)
  
  # Styles for the data table row/column names
  
  TABLE_ROWNAMES_STYLE <- CellStyle(wb) + Font(wb, isBold=TRUE) +
    Alignment(wrapText=TRUE, horizontal="ALIGN_CENTER") +
    Border(color="#4cc0e0", position=c("TOP", "BOTTOM"), 
           pen=c("BORDER_THIN", "BORDER_THIN")) 
  
  sheet <- createSheet(wb, sheetName = "Filters Applied")
  # Add title
  xlsx.addTitle(sheet, rowIndex=1, title="Filters Applied",
                titleStyle = TITLE_STYLE)
  convertToReadableName <- function(values, optionSet) {
    temp <- list()
    append(temp, names(optionSet[optionSet %in% values]))
  }
  
  # Add a table
  addOptionToSheet <- function(sheet, sheetRow, values, optionSet, name) {
    print(name)
    TABLE_ROWNAMES_STYLE <- CellStyle(wb) + Font(wb, isBold=TRUE) +
      Alignment(wrapText=TRUE, horizontal="ALIGN_CENTER") +
      Border(color="#4cc0e0", position=c("TOP", "BOTTOM"), 
             pen=c("BORDER_THIN", "BORDER_THIN")) 
    addDataFrame(data.frame(convertToReadableName(values, optionSet), row.names = name), sheet, startRow=sheetRow, startColumn=1, 
                 rownamesStyle = TABLE_ROWNAMES_STYLE,
                 row.names = TRUE, col.names = FALSE)
    print(paste("Done:", name))
  }
  addOptionToSheet(sheet, 3, filters$domestic, domesticOptions, "Domestic Status")
  addOptionToSheet(sheet, 4, filters$sex, sexOptions, "Sex")
  addOptionToSheet(sheet, 5, filters$ethnicity, ethnicityOptions, "Ethnicity")
  addOptionToSheet(sheet, 6, filters$young_grad, youngGradOptions, "Young or Mature graduate")
  addOptionToSheet(sheet, 7, filters$studyLevel, studyLevelOptions, "Level of Study")
  if (!is.na(filters$fieldOfStudy)) {
    print(filters$fieldOfStudy)
    addOptionToSheet(sheet, 8, filters$fieldOfStudy, fieldOfStudyOptions, "Field of Study")
  }
  addDataFrame(data.frame(filters$subsector, row.names = "Subsector"), sheet, startRow=9, startColumn=1, 
               rownamesStyle = TABLE_ROWNAMES_STYLE,
               row.names = TRUE, col.names = FALSE)
  setColumnWidth(sheet, colIndex=c(1:10), colWidth=20)
  #addDataFrame(data.frame(convertToReadableName(filters$sex, sexOptions), row.names = "Sex"), sheet, startRow=4, startColumn=1, 
  #            rownamesStyle = TABLE_ROWNAMES_STYLE,
  #           row.names = TRUE, col.names = FALSE)
}
addSheetsForIndicators <- function(wb, indicators, selectedData, dims = c("month")) {
  TITLE_STYLE <- CellStyle(wb)+ Font(wb,  heightInPoints=16, 
                                     color="#4d6d8c", isBold=TRUE)
  SUB_TITLE_STYLE <- CellStyle(wb) + 
    Font(wb,  heightInPoints=14, 
         isItalic=TRUE, isBold=FALSE)
  # Styles for the data table row/column names
  TABLE_ROWNAMES_STYLE <- CellStyle(wb) + Font(wb, isBold=TRUE)
  TABLE_COLNAMES_STYLE <- CellStyle(wb) + Font(wb, isBold=TRUE) +
    Alignment(wrapText=TRUE, horizontal="ALIGN_CENTER") +
    Border(color="#4cc0e0", position=c("TOP", "BOTTOM"), 
           pen=c("BORDER_THIN", "BORDER_THIN")) 
  
  
  for (indicator in unique(indicators)) {
    indicatorsSelected <- indicator_names.v2[indicator]
    indData <- getDataForIndicatorOrMagnitude(indicator, selectedData, dims)
    #indData <- indData[order(dims),]
    # TODO: sort data for cohorts
    sheet <- createSheet(wb, sheetName = fitIndicatorNameToSheet(indicator))
    # Add title
    xlsx.addTitle(sheet, rowIndex=1, title=indicator,
                  titleStyle = TITLE_STYLE)
    # Add sub title
    xlsx.addTitle(sheet, rowIndex=2, 
                  title=indicatorDecriptions[indicator, "description"],
                  titleStyle = SUB_TITLE_STYLE)
    # Add a table
    addDataFrame(indData, sheet, startRow=3, startColumn=1, 
                 colnamesStyle = TABLE_COLNAMES_STYLE,
                 row.names = FALSE)
    # Change column width
    setColumnWidth(sheet, colIndex=c(1:(ncol(indData)+1)), colWidth=20)
    
    #write.xlsx(indData,
    #           file, sheetName = indicator,
    #           col.names = TRUE, row.names = FALSE, append = TRUE)
  }
}


setObservableAll <- function(input, session, controlName) {
  moduleEvn <- environment()
  eth_all <- FALSE
  # what to do when all and other options are selected?
  observe({
    print ("observable triggered")
    # if contains the all option
    if (-1 %in% input[[controlName]] && length(input[[controlName]]) > 1) {
      v <- get("eth_all", envir = moduleEvn)
      # works for removing others, not sure about the other way around.
      if (v) {
        # if it did, remove all option
        assign("eth_all",FALSE, envir = moduleEvn)
        #input$ethnicity = -1
        updateSelectInput(session, controlName, selected = -1)
        print("selection changed, all to remove")
      } else{
        # if it did not have all before, remove other options
        assign("eth_all",TRUE, envir = moduleEvn)
        print("all first select, remove other options")
        print(input[[controlName]] != -1)
        
        updateSelectInput(session, controlName, selected = input[[controlName]][input[[controlName]] != -1])
      }
    }
  })
  print("observable setup")
}

indicatorOptionsReative <- function(input, aggregationApplied) {
  reactive({
    if (is.null(input$domestic)) {
      options <- indicatorOptions.int # should only happen during load.
    }
    else if(input$domestic == 1) {
      options <- indicatorOptions.dom
    } else { options <- indicatorOptions.int}
    print(aggregationApplied())
    if (aggregationApplied()) {
      options[options != "Earnings from wages or salary (median)"]
    } else {
      options
    }
  })
}