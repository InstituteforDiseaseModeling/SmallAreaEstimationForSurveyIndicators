saveModelValues<-function(model_data,unmet_mod,mcpr_mod,path_results,admin_level,country){
  
  
  # Purpose of this function: This function saves the model outputs in a particular format.
  
  unmet_Model<-loadRData(paste0(path_results,"Unmet_Need_",admin_level,"_",unmet_mod,".RDATA"))
  
  
  mcpr_Model<-loadRData(paste0(path_results,"mCPR_",admin_level,"_",mcpr_mod,".RDATA"))
  
  
  
  model_data$unmet.mdn<-expit(unmet_Model$summary.fitted.values$`0.5quant`)
  model_data$unmet.up<-expit(unmet_Model$summary.fitted.values$`0.975quant`)
  model_data$unmet.low<-expit(unmet_Model$summary.fitted.values$`0.025quant`)
  
  model_data$mcpr.mdn<-expit(mcpr_Model$summary.fitted.values$`0.5quant`)
  model_data$mcpr.up<-expit(mcpr_Model$summary.fitted.values$`0.975quant`)
  model_data$mcpr.low<-expit(mcpr_Model$summary.fitted.values$`0.025quant`)

mcpr_preds<-model_data
unmet_preds<-model_data

adminName <- mcpr_preds$state
year <- mcpr_preds$year

mcpr_low <- mcpr_preds$mcpr.low
mcpr_median <- mcpr_preds$mcpr.mdn
mcpr_high <- mcpr_preds$mcpr.up

unmet_low <- unmet_preds$unmet.low
unmet_median <- unmet_preds$unmet.mdn
unmet_high <- unmet_preds$unmet.up

modelResults <- data.frame(year, adminName, mcpr_low, mcpr_median, mcpr_high, unmet_low,
                           unmet_median, unmet_high) 

write_csv(as.data.frame(modelResults),
          paste0(path_results,country,"_",mapAdmin,".csv"))

return(list(mcpr_preds=mcpr_preds,unmet_preds=unmet_preds))
}