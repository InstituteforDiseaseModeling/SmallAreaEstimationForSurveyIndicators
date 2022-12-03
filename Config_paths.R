#########################################################################
####
#### This folder will 
#### 3. Check to see if the Project Folder exist, if not, create it
#### 4. Check if country folder within project exists, if not, create it and
####   a. Intermediate data
####   b. Processed data
####   c. Figures
####   d. Model results
#### 5. Load general functions
#### 6. Load project specific functions
#### 7. Set paths
####
#### 
#########################################################################

#########################################################################
# -- 3. Check to see if the Project Folder exists, if not, create it -- #
#########################################################################

if(!("Projects"%in%list.files(projectResultsDir))){
  dir.create(file.path(paste0(projectResultsDir,"Projects/")),showWarnings = F)
}

if(!(ProjectName%in%list.files(paste0(projectResultsDir,"Projects/")))){
  dir.create(file.path(paste0(projectResultsDir,"Projects/",ProjectName)),showWarnings = F)
  }

##################################################################################
# -- 4. Check for country folder, if doesn't exist, add all necessary folders -- #
##################################################################################
SAE_Project_Country<-paste0(projectResultsDir,"Projects/",ProjectName,"/",country)

if(!(country%in%list.files(paste0(projectResultsDir,"Projects/",ProjectName,"/")))){
  dir.create(file.path(SAE_Project_Country),showWarnings = F)
  dir.create(file.path(paste0(SAE_Project_Country,"/Figures")),showWarnings = F)
  dir.create(file.path(paste0(SAE_Project_Country,"/Results")),showWarnings = F)
  dir.create(file.path(paste0(SAE_Project_Country,"/IntermediateData")),showWarnings = F)
  dir.create(file.path(paste0(SAE_Project_Country,"/FinalDataFiles")),showWarnings = F)
  dir.create(file.path(paste0(SAE_Project_Country,"/ModelResults")),showWarnings = F)
  dir.create(file.path(paste0(SAE_Project_Country,"/SelectedModel")),showWarnings = F)
  dir.create(file.path(paste0(SAE_Project_Country,"/logfiles")),showWarnings = F)
}

##########################################
# -- 5. Loading general use functions -- #
##########################################
General_Dir<-paste0(codeRepoName,"General_utils/")
Gen_file_sources = paste0(SAEDir,General_Dir,
                          list.files(paste0(SAEDir,General_Dir),
                                     pattern="*.R"))

quiet(sapply(Gen_file_sources,source,.GlobalEnv))

#################################################
# -- 6. Loading in the project-specific files - #
#################################################
Project_Dir<-paste0(codeRepoName,"Project_specific_utils/",ProjectName,"/")

Proj_file_sources = paste0(SAEDir,
                           Project_Dir,list.files(paste0(SAEDir,Project_Dir),
                                                  pattern="*.R"))
if(length(list.files(Project_Dir))==0){
  warning(paste0("There are currently no project specific functions for this project in ",Project_Dir,"."))
}else quiet(sapply(Proj_file_sources,source,.GlobalEnv))

################################
# -- 7. Set necessary paths -- #
################################

## Shapefiles 
#shapeFilePath = paste0(RawDataDir,"RawData/shapefiles/",country,"/",country,"_l",substring(mapAdmin,6,6),"_shapes")
shapeFilePath = paste0(RawDataDir,"RawData/shapefiles/",country)
shapefilelayer = paste0(country,"_l",substring(mapAdmin,6,6),"_shapes")
## GPS location
GPSfilelocation = paste0(RawDataDir,"RawData/DHS/")

## RawData location
RawDatafilelocation = paste0(RawDataDir,"RawData/")

## ModelResults location
ModelResultsfilelocation = paste0(SAE_Project_Country,"/ModelResults/")

## SelectedModel location
SelectedModelfilelocation = paste0(SAE_Project_Country,"/SelectedModel/")

## Intermediate Data Files
pathToIntermediateDataFiles = paste0(SAE_Project_Country,"/IntermediateData/")

## Aggregated data
pathToAggregatedCSV = paste0(SAE_Project_Country,"/FinalDataFiles/",country,"_",mapAdmin,".csv")

## Results
pathToResults=paste0(SAE_Project_Country,"/Results/")

## Figures
pathToFigures_country=paste0(SAE_Project_Country,"/Figures/")

## Figures Africa
pathToFigures=paste0(projectResultsDir,"Projects/",ProjectName,"/Africa/")

## Special survey extraction functions

pathToSpecialSurveyExtraction = paste0(SAEDir,codeRepoName,"General_utils/specialSurveyExtractionFunctions/")

## Path to Africa maps 
if(exists("PlotAllOfAfrica")&&PlotAllOfAfrica){
pathToFiguresForContinent = paste0(projectResultsDir,"Projects/",ProjectName,"/AfricaMaps/")
dir.create(file.path(pathToFiguresForContinent),showWarnings = F)
}
## Path to Africa maps 
if(exists("PlotDiffAllOfAfrica")&&PlotDiffAllOfAfrica){
pathToFiguresForContinentDiff = paste0(projectResultsDir,"Projects/",ProjectName,"/AfricaMapsDiff/")
dir.create(file.path(pathToFiguresForContinentDiff),showWarnings = F)
}
## Path to OP maps 
if(exists("PlotOPCountries")&&PlotOPCountries){
pathToFiguresForOP= paste0(projectResultsDir,"Projects/",ProjectName,"/OPMaps/")
dir.create(file.path(pathToFiguresForOP),showWarnings = F)
}
## Path to OP Diff maps 
if(exists("PlotDiffOPCountries")&&PlotDiffOPCountries){
pathToFiguresForDiffOP= paste0(projectResultsDir,"Projects/",ProjectName,"/OPDiffMaps/")
dir.create(file.path(pathToFiguresForDiffOP),showWarnings = F)
}
## Path to project directory

pathToProjectDirectory <- paste0(projectResultsDir,"Projects/",ProjectName,"/")

## Set default of cohortModel to false
if(!exists("cohortModel")){cohortModel<-F}
