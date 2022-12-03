###############################################################################################
#####
##### This file needs to add the FP indicators, and sub-groups to the raw data set
##### This will be a project-specific file.

add_DHS_indicators<-function(dhs,dhs_ch,survey.id){
  
  ################################
  # -- creating the subgroups -- #
  ################################
  # a coarse age recode #
  dhs<-dhs%>%mutate(Parity=recode(as.numeric(v220),
                  "0"="0",
                  "1"="1+",
                  "2"="1+",
                  "3"="1+",
                  "4"="1+",
                  "5"="1+",
                  "6"="1+",
                  "6+"="1+"
  ),
  subgroup=paste0("Parity ",Parity),
  subgroup=ifelse(is.na(Parity),NA,subgroup)) 
  

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

