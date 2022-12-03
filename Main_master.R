#######################################################################
## Main.R - A file to run SAE for FP for any Country and Admin level ##
#######################################################################
# system.time({

# - clear the deck - #
rm(list=ls())

# - name of config file - #
project_config_path<-"SmallAreaEstimationForSurveyIndicators/Config_projectSpecific/FP_Parity.R"

###############################################
# Specify paths:
# SAEDir ->  specify the location of this Main.R on your platform
# RawDataDir -> You will need to setup a directory where there are two folders: DHS and shapefiles. Put the required DHS data in the DHS folder and the GADM shapefile data into shapefiles. 
# codeRepoName ->  This is just to specify what you call the codeRepoName. 
# projectResultsDir ->  This specifies where you are going to save the output of each project.
###############################################

SAEDir<-"FILL IN"
setwd(SAEDir)

RawDataDir <- "FILL IN"
codeRepoName <- "SmallAreaEstimationForSurveyIndicators/"
projectResultsDir <- "FILL IN"

###############################################
# Load the project specific config,and check 
# the config - #
###############################################
source(paste0(codeRepoName,"Config_project.R"))

for(countryIndex in 1:length(countryList)){
  
  country <- countryList[countryIndex]
  
  ###############################################
  # - load the packages, paths, and functions - #
  ###############################################
  source(paste0(codeRepoName,"Config_paths.R"))
  
  ##################################
  # - read in the shapefile data - #
  ##################################
  shape_data<-readInShapefile(path=shapeFilePath,shapefilelayer)
  shape<-shape_data$shape
  
  #######################################
  # - option to analyze raw data sets - #
  #######################################
  
  process_raw_survey_data(ProcessData,
                          shape,
                          pathToMasterSurveyList,
                          RawDatafilelocation,
                          pathToIntermediateDataFiles,
                          country,
                          pathToSpecialSurveyExtraction)
  
  
  
  ###############################################################
  # # - aggregate and save data. if already saved comment out and
  # # - move to the next function
  ###############################################################
  
  data<-readInAggregateData(path_in=pathToIntermediateDataFiles,
                            path_out=pathToAggregatedCSV)
  
  ######################################################################################
  # - format the data for the models.
  ######################################################################################
  
  FormattedData<-formatDataForModels(path=NULL,processed_data=data,
                                     thresh=0.001,
                                     indicators,
                                     AdminKey=shape_data$adminName_key,
                                     startYear,
                                     predYear,
                                     pathToResults)
  
  
  
  #############################
  # - fit all of the models - #
  #############################
  #system.time({
  fitAllModelsParallel(model_data=FormattedData,
                       path_results=pathToResults,
                       SubGroup=unique(FormattedData$subgroup), # should be able to provide an individual or default to all
                       outcome=indicators,
                       adjacency_matrix=shape_data$mat,
                       admin_level=mapAdmin,
                       cohortModel,
                       FitModels)
  #})
  
  # - if the models have already been fit, comment out the above _ #
  
  ###############################
  # - look at selected models - #
  ###############################
  res<-read_csv(paste0(pathToResults,"ModelSelection_",mapAdmin,".csv"))
  print(res)
  
  # - this can be swapped for a matrix that forces different choices - #
  selected_models<-group_by(res,outcome,subgroup)%>%summarize( selected_DIC=model[which(DIC==min(DIC))],
                                                               selected_LCPO=model[which(LCPO==max(LCPO))],
                                                               selected_WAIC=model[which(WAIC==min(WAIC))])%>%mutate(selected=selected_LCPO)
  
  SaveSelectedModelOutput(selected_models,
                          pathToResults,
                          mapAdmin,
                          country,
                          FormattedData,
                          ModelResultsfilelocation,
                          SelectedModelfilelocation)
  
  #################################################################################
  # - plot the time series for all indicators and subgroups for each admin unit - #
  #################################################################################
  plotTimeSeriesParallel(admin_level=mapAdmin,
                         path_results=pathToResults,
                         figure_path=pathToFigures_country,
                         FormattedData,
                         selected_models,
                         plotting_limit=mround(quantile(res$maxPred,0.85),0.05),
                         PlotTimeSeries)
  
  # - generate maps with selected models - #
  plotMapsParallel(admin_level=mapAdmin,
                  path_results=pathToResults,
                  figure_path=pathToFigures_country,
                  FormattedData,
                  selected_models,
                  shape,
                  plotting_limit=mround(quantile(res$maxPred,0.75),0.05),
                  include_legend,
                  PlotMaps)
  
}


