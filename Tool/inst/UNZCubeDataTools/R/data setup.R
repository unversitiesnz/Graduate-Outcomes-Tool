ChangeNamesOnData <- function (indicator.data) {
  names(indicator.data)[names(indicator.data) == 'snz_sex_code'] <- 'sex'
  names(indicator.data)[names(indicator.data) == 'demo_eth'] <- 'ethnicity'
  subset(indicator.data, select = -c(ind))
}
if (!exists("dataDir")) {
  dataDir = '.';
}
#cube = readRDS(file.path(dataDir, "cube.rds"))
load(file.path(dataDir, "datacube.RData"))
load(file.path(dataDir, "cubehelpers.RData"))


indicator_names = list(
  overseas = "Overseas",
  all_benefit = "On a benefit",
  job_seeker_benefit = "Job Seeker benefit",
  enrolled_tertiary_study = "Enrolled in tertiary study",
  enrolled_university = "Enrolled at university",
  enrolled_higher_university = "Enrolled in higher level studies at university",
  employed = "Employed",
  employed_wns = "Employed on wages or salaries",
  wns_mean = "Earnings from wages or salary (mean)",
  wns_median = "Earnings from wages or salary (median)",
  regional_mobility = "Regional mobility",
  district_mobility = "District mobility",
  employer_change = "Employer change"
)

indicator_names.v2 = list(
  "Overseas" = "overseas",
  "On a benefit" = "benefit",
  "Job Seeker benefit" = "job_seeker",
  "Enrolled in tertiary study" = "prog",
  "Enrolled at university" = "uni",
  "Enrolled in higher level studies at university" = "uni_hi",
  "Employed" = "wns_sei",
  "Employed on wages or salaries" = "wns_income",
  "Not in labour force or education" = "not_in_lf",
  "Earnings from wages or salary (mean)" = "wns_income",
  "Earnings from wages or salary (median)" = "wns_income",
  "Regional mobility" = "wns_reg_ch",
  "District mobility" = "wns_ta_ch",
  "Employer change" = "wns_pbn_ch"
)


# cleaning
#remove(cube)

#cube_income = readRDS(file.path(dataDir, "cube_inc.rds"))
#datacube.wns_income = ChangeNamesOnData(cube_income)
