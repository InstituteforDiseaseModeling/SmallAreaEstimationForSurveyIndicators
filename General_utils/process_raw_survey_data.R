process_raw_survey_data<-function(ProcessData,shape,pathToMasterSurveyList,RawDatafilelocation,pathToIntermediateDataFiles,countryName,pathToSpecialSurveyExtraction){
  
  # Purpose of this function: This is the high-level function that for every country with more than one survey, it extracts
  # the required DHS data for the model fitting.
  
  if(ProcessData){
    
    # Need to load the master survey excel sheet ## 
    surveyList <- read_excel(pathToMasterSurveyList)
    
    # Subset to the country
    countrySurveyList <- subset(surveyList,Country==countryName)
    
    # Count number of survey's for country
    numberOfSurveys <- sum(countrySurveyList$Country== countryName)
    
    if(numberOfSurveys>0){
      
      # For loop for all of the surveys.  This could be changed to be in parallel
      for (survey in 1:numberOfSurveys){
        
        # DHS with GPS specific extraction 
        if((countrySurveyList$Survey_Type[survey]=="DHS")&&(countrySurveyList$admin1_Only[survey] == 0)) {
          
           if(countrySurveyList$SpecialProcessing[survey]==0){  
              DHS_ExtractionWithGPS(paste0(RawDatafilelocation,"DHS/"),
                                 gps.file=countrySurveyList$GPS_Filename[survey],
                                 shape,
                                 survey.id=countrySurveyList$Survey.ID[survey],
                                 survey.file.ir=countrySurveyList$IR_Survey_Filename[survey],
                                 survey.file.ch=countrySurveyList$CH_Survey_Filename[survey],
                                 strata_vars=as.character(countrySurveyList$strat_var[survey]),
                                 id_var=as.character(countrySurveyList$id_var[survey]),
                                 countryName,
                                 surveyYear=as.character(countrySurveyList$Year[survey]),
                                 pathToIntermediateDataFiles)
           } else{
             source(paste0(pathToSpecialSurveyExtraction,"DHS/","Ethiopia","SpecialSurvey.R"))
             EthiopiaSpecialSurvey(paste0(RawDatafilelocation,"DHS/"),
                                   gps.file=countrySurveyList$GPS_Filename[survey],
                                   shape,
                                   survey.id=countrySurveyList$Survey.ID[survey],
                                   survey.file.ir=countrySurveyList$IR_Survey_Filename[survey],
                                   survey.file.ch=countrySurveyList$CH_Survey_Filename[survey],
                                   strata_vars=as.character(countrySurveyList$strat_var[survey]),
                                   id_var=as.character(countrySurveyList$id_var[survey]),
                                   countryName,
                                   surveyYear=as.character(countrySurveyList$Year[survey]),
                                   pathToIntermediateDataFiles)
             
             #  I can't seem to figure this out.  
              # source(paste0(pathToSpecialSurveyExtraction,"DHS/",country,"SpecialSurvey.R"))
              #        eval(funcall,inputs)
              #       paste0(RawDatafilelocation,"DHS/"),
              #        gps.file=countrySurveyList$GPS_Filename[survey],
              #        shape,
              #        survey.id=countrySurveyList$Survey.ID[survey],
              #        survey.file=countrySurveyList$IR_Survey_Filename[survey],
              #        strata_vars=as.character(countrySurveyList$strat_var[survey]),
              #        countryName,
              #        surveyYear=as.character(countrySurveyList$Year[survey]),
              #        pathToIntermediateDataFiles)
           }
        }
        # DHS without GPS specific extraction
        
        # MICS specific extraction
        
        # PMA specific extraction
        
        # 
      }
    }
    else{
      disp(paste0("There is an issue with finding survey details 
           in the master survey list for ",country,". Check the 
          spelling and the list."))
    }
  }
}
