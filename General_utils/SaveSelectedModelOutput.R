SaveSelectedModelOutput<-function(selected_models,
                                  pathToResults,
                                  mapAdmin,
                                  country,
                                  FormattedData,
                                  ModelResultsfilelocation,
                                  SelectedModelfilelocation){
  
  
  # Purpose of this function: This function saves the selected model output in order to be human readable and ingested to the dashboard.
  
  write_excel_csv(selected_models,paste0(SelectedModelfilelocation,country,"_",mapAdmin,"_SelectedModels.csv"))
  
  for(ind in 1:nrow(selected_models)){
  
    # ind<-1
    
  # - subset by subgroup - #
  direct_data<-FormattedData
  if(!is.na(selected_models$subgroup[ind])){
    direct_data<-filter(FormattedData,subgroup==selected_models$subgroup[ind])
  }

  
  # - set the outcome variable - #
  outcome_variable<-selected_models$outcome[ind]
  se_variable<-paste0("se.",selected_models$outcome[ind])
  # direct_data$outcome<-unlist(direct_data[,outcome_variable])
  # names(direct_data$outcome)<-"outcome"
  # direct_data$SE<-unlist(direct_data[,se_variable])
  # names(direct_data$SE)<-"SE"
  
  # - subselect just the variable of interest - #
 sub_direct_data<-direct_data[,c("subgroup","state",outcome_variable,se_variable,"year","country","survey","dist.id","period.id")]

  # - load in the relevant model output - #
  group_name_save<-paste0(unlist(strsplit(as.character(selected_models$subgroup[ind]),":")),collapse="_")
  if(is.na(selected_models$subgroup[ind])){
    group_name_save<-"ALL"
  }
  preds<-loadRData(paste0(pathToResults,selected_models$outcome[ind],"_",mapAdmin,"_",group_name_save,"_model",selected_models$selected[ind],".RDATA"))
  
  # - add the predictions and intervals - #
  sub_direct_data$pred<-expit(preds$summary.fitted.values$`0.5quant`)
  sub_direct_data$pred_upper<-expit(preds$summary.fitted.values$`0.975quant`)
  sub_direct_data$pred_lower<-expit(preds$summary.fitted.values$`0.025quant`)
  
  
  write_excel_csv(sub_direct_data,paste0(ModelResultsfilelocation,selected_models$outcome[ind],
                                   "_",mapAdmin,"_",group_name_save,"_model",
                                   selected_models$selected[ind],"_preds.csv"))
  
  }
  
}