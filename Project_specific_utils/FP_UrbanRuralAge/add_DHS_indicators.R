###############################################################################################
#####
##### This file needs to add the FP indicators, and sub-groups to the raw data set
##### This will be a project-specific file.

add_DHS_indicators<-function(dhs,dhs_ch,survey.id){
  
  ################################
  # -- creating the subgroups -- #
  ################################
  # a coarse age recode #
  dhs<-dhs%>%mutate(Age=recode(as.character(v013),
                               "15-19"="15-24",
                               "20-24"="15-24",
                               "25-29"="25+",
                               "30-34"="25+",
                               "35-39"="25+",
                               "40-44"="25+",
                               "45-49"="25+",
                               "1"="15-24",
                               "2"="15-24",
                               "3"="25+",
                               "4"="25+",
                               "5"="25+",
                               "6"="25+",
                               "7"="25+",
                               "8"="25+",
                               "9"="25+",
                               "10"="25+"
  ),UrbanRural=recode(as.numeric(v102),
                  "1"="urban",
                  "2"="rural"),
  subgroup=paste0("Age ",Age,":UrbanRural ",UrbanRural))
  

  ################################
  # -- Modern Method Variable -- #
  ################################
  
  if(sum(c("modern method","3",3)%in%unique(dhs$v313))>1){
    dhs<-dhs%>%mutate(modern_method=as.numeric(as.character(v313)%in%c("modern method","3",3)),
                      modern_method=ifelse(!is.na(v313),modern_method,NA))
  }
  
  if(sum(c("modern method","3",3)%in%unique(dhs$v313))==0){ # this variable was recoded at some point
    dhs<-dhs%>%mutate(modern_method=as.numeric(as.character(v313)%in%c("modern method","2",2)),
                      modern_method=ifelse(!is.na(v313),modern_method,NA))
  }
  

  #############################
  # -- Unmet Need Variable -- #
  #############################
  
  # Unmet Need, NA if doesn't have it #
  if(sum(c("v624","v626a")%in%names(dhs))>0){ # this variable was recoded at some point
    dhs<-Unmet(dhs, SurveyID=survey.id)
  }else{
    dhs$unmet_need<-dhs$unmet_need_space<-dhs$unmet_need_limit<-NA
  }
  
  #############################
  # -- Traditonal method Variable -- #
  #############################
  
  dhs<-dhs%>%mutate(any_method=as.numeric(as.character(v313)%in%c("modern method","3",3,"2",2,"traditional method",1,"1","folkloric method")),
      any_method=ifelse(!is.na(v313),any_method,NA))

  dhs<-dhs%>%mutate(traditional_method=as.numeric(any_method!=modern_method))
  
  return(dhs)
}

