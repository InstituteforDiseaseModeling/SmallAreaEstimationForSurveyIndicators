#########################################################################
####
#### This folder will 
#### 0. Load in ddpcr package (for quiet function)
#### 1. Read in the project config file
#### 2. Check to see if the data for the country exists
#########################################################################

###############################
# -- 0. Load ddpcr package -- #
###############################
library(ddpcr)

#########################################
# -- 1. Load the project config file -- #
#########################################
source(paste0(project_path,"project_config.R"))

############################################################
# -- 2. Check to see if the data for the country exists -- #
############################################################

library(readxl)

## Need to check to see if there is survey data for the country in the Master Survey List location
pathToMasterSurveyList = paste0(RawDataDir,"RawData/surveyCodeBook.xlsx")

# Need to load the master survey excel sheet ## 
surveyList <- read_excel(pathToMasterSurveyList)

if((length(country)==1)&& (country == "ALL")){
  countryList <- unique(surveyList$Country)
  
} else if(length(country)>1){
  #Check to make sure each country provided is in the  
  for(countryInList in 1:length(country)){
    if(!(country[countryInList]%in%unique(surveyList$Country))){
      stop("There is a country in your list not available or not spelled correctly. Please check available countries in surveyCodeBook.xlsx.")
    }
  }  
  countryList <- country
  
} else {
  if(!(country%in%list.files(paste0(RawDataDir,"RawData/shapefiles/")))){
    stop("This country is not available or not spelled correctly. Please check available countries in surveyCodeBook.xlsx.")
  }
  countryList <- country
}
numberOfCountries <- length(countryList)