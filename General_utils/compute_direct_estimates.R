compute_direct_estimates <- function(my.svydesign,indicators,sub_groups,states,dhs){

  # Purpose of this function: This function computes all of the direct estimates
  
  #################################################
  # -- set up empty objects for survey results -- #
  #################################################
  
  SubGroupResults<-expand.grid(subgroup=sub_groups,state=states)
  SubGroupResults<-SubGroupResults%>%filter(!is.na(subgroup))
  
  AllResults<-data.frame(subgroup="ALL",state=states)
  
  ############################
  # -- set up the formula -- #
  ############################
  
  # - need to subset if the indicator was not collected - #
  # this will provide indices for variables that are not completely missing #
  include_indicators<-which(apply(dhs[,indicators],2,function(x)mean(is.na(x)))<1)
  
  # if none of the variables are included in the survey the length==0 and you will want to skip this processing
  # step.  This happens, for example, in the 1997 Senegal survey, which did not include any RI indicators
  if(length(include_indicators)==0){warning("All indicators were missing. Unable to calculate direct estimates.")

            # - loop through all variables.  This is not the most efficient - #
      for(m in 1:length(indicators)){
        
        AllResults[,indicators[m]]<-NA
        AllResults[,paste0("se.",indicators[m])]<-NA
        
        # - If there are no subgroups then you cannot assign a value - #
        # - This way you can still do the rbind at the end - #
        
        if(nrow(SubGroupResults)>0){
        SubGroupResults[,indicators[m]]<-NA
        SubGroupResults[,paste0("se.",indicators[m])]<-NA
        }
        if(nrow(SubGroupResults)==0){
          SubGroupResults[,indicators[m]]<-NULL
          SubGroupResults[,paste0("se.",indicators[m])]<-NULL
        }
        
      }
      
      
    } #### End of the 0 length 'if' statement
    
  if(length(include_indicators)>0){
  
  formula<-as.formula(paste0("~",paste(indicators[include_indicators],collapse="+")))
  
 
  ###################################
  # -- collapsing over subgroups -- #
  ###################################
  ByState<-svyby(formula,
               ~state,my.svydesign,svymean,na.rm=T)
  
  # dim(AllResults)
  AllResults<-AllResults%>%left_join(ByState)%>%mutate(subgroup=as.character(subgroup))
  # dim(AllResults)  
  
  ################################
  # -- by admin and subgroups -- #
  ################################
  
  if(sum(!is.na(sub_groups))>0){ # - required if there are no subgroups - #
  BySubgroupAndState<-svyby(formula,
              ~subgroup+state,my.svydesign,svymean,na.rm=T)

  # dim(SubGroupResults)
    SubGroupResults<-SubGroupResults%>%left_join(BySubgroupAndState)%>%mutate(subgroup=as.character(subgroup))
  # dim(SubGroupResults)
  }
  
    # - if there is only one indicator left, there won't be all the right columns later on - #
    # - need to change the name of the se variable and add in the other columns with NAs - #
    if(length(include_indicators)==1){
      
      names(AllResults)[which(names(AllResults)=="se")]<-paste0("se.",indicators[include_indicators])
      names(SubGroupResults)[which(names(SubGroupResults)=="se")]<-paste0("se.",indicators[include_indicators])
      
   
     }
  
  # - loop through all variables not included - #
  for(m in which(!indicators%in%names(SubGroupResults))){
    
    AllResults[,indicators[m]]<-NA
    AllResults[,paste0("se.",indicators[m])]<-NA
    
    SubGroupResults[,indicators[m]]<-NA
    SubGroupResults[,paste0("se.",indicators[m])]<-NA
    
  }
  
} # end of if statement
    ########################################
    # -- combine the results and return -- #
    ########################################
 final<-rbind(AllResults,SubGroupResults)

    
    # - will need to make sure the columns are ordered the same way they would be for surveys will all variables - #

    var_names<-names(final)[1:2]
    for(k in 1:length(indicators)){
      var_names<-c(var_names,indicators[k],paste0("se.",indicators[k]))
    }
    
final<-final[,var_names]
  return(final)
}