
formatDataForModels<-function(path=NULL,processed_data,thresh=0.001,indicators,AdminKey,startYear,predYear,pathToResults){
  
  # Purpose of this function: This function formats the data in preparation for the model fit.  It saves an intermediate formatted data file.
  
  # thresh sets observations very near 0 to NA due to numeric instability
  if(is.null(path)&is.null(processed_data)){
    print("Must specify either path or processed_data")
    stop()
  }
  
  if(!is.null(path)&!is.null(processed_data)){
    print("Can only specify either path or processed_data")
    stop()
  }
  
  if(!is.null(path)){
   quiet(processed_data<-read_csv(path))}

  # this should be generic for the indicators #
  
  
  for(i in 1:length(indicators)){
  
    
    # need to create the variables without knowing their names first #
    processed_data$tmp_indicator<-unlist(processed_data[,indicators[i]])
    processed_data$tmp_se<-unlist(processed_data[,paste0("se.",indicators[i])])
    
    processed_data<-processed_data%>%mutate(logit_tmp=ifelse(!is.na(tmp_indicator),logit(tmp_indicator),NA),
                                            var_logit_tmp=(tmp_se^2)/(tmp_indicator^2*(1-tmp_indicator)^2),
                                            logit_tmp=ifelse(tmp_indicator<thresh,NA,logit_tmp),
                                            var_logit_tmp=ifelse(tmp_se<thresh,NA,var_logit_tmp))
    
    processed_data$logit_tmp[is.na(processed_data$var_logit_tmp)]<-NA
    
    names(processed_data)[which(names(processed_data)=="logit_tmp")]<-paste0("logit_",indicators[i])
    names(processed_data)[which(names(processed_data)=="var_logit_tmp")]<-paste0("var_logit_",indicators[i])
    
    processed_data<-processed_data%>%dplyr::select(-tmp_indicator,-tmp_se)
    
  }

#-- if the subgroups are numeric, we don't want to expand the grid by subgroup --#
  x<-as.numeric(unique(processed_data$subgroup)[-which(unique(processed_data$subgroup)=="ALL")])
  
  if(sum(is.na(x))==0 & length(x)>0){
    # processed_data<-processed_data%>%mutate(survey_id=as.numeric(as.factor(survey)))
    processed_data<-processed_data%>%filter(subgroup!="ALL")%>%mutate(year=as.numeric(subgroup))
    # grid<-expand.grid(row_num=AdminKey$row_num,year=min(processed_data$year):predYear,survey_id=c(unique(processed_data$survey_id),NA))
    grid<-expand.grid(row_num=AdminKey$row_num,year=min(processed_data$year):predYear)
    
    # - random effects variables - #
    quiet(grid<-grid%>%left_join(AdminKey))
    # grid<-grid%>%mutate(period.id=as.numeric(as.factor(year)),period.id2=period.id,period.id3=period.id,
    #                     dist.id=row_num,dist.id2=dist.id,dist.id3=dist.id,survey_id2=survey_id,survey_id3=survey_id)
    
    grid<-grid%>%mutate(period.id=as.numeric(as.factor(year)),period.id2=period.id,period.id3=period.id,
                        dist.id=row_num,dist.id2=dist.id,dist.id3=dist.id)
  }
  if(sum(is.na(x))>0 | length(x)==0){
  grid<-expand.grid(row_num=AdminKey$row_num,year=startYear:predYear,subgroup=unique(processed_data$subgroup))
  # - random effects variables - #
  quiet(grid<-grid%>%left_join(AdminKey))
  grid<-grid%>%mutate(period.id=as.factor(year),period.id2=period.id,period.id3=period.id,
                      dist.id=row_num,dist.id2=dist.id,dist.id3=dist.id)
  }

  
  # - merge this in with the processed data - #
  # dim(processed_data)
 quiet(processed_data<-processed_data%>%right_join(grid)%>%arrange(row_num,year))

 FormattedData <- processed_data
 
 save(FormattedData,file=paste0(pathToResults,"FormattedData_",country,".RDATA"))
 
return(processed_data)

}