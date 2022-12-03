printSelectedModels<-function(admin_level,measure="WAIC",path){
  
  # Purpose of this function: This outputs the selected models using WAIC.
  
  quiet(DataForSelection_mCPR<-read_csv(paste0(path,"ModelSelection_mCPR_",admin_level,".csv")))
  quiet(DataForSelection_Unmet<-read_csv(paste0(path,"ModelSelection_Unmet_Need_",admin_level,".csv")))
  
  # can later expand for DIC and LCPO if necessary #
  mCPR_mod<-which(DataForSelection_mCPR[,measure]==min(DataForSelection_mCPR[,measure]))
  UN_mod<-which(DataForSelection_Unmet[,measure]==min(DataForSelection_Unmet[,measure]))
  writeLines(paste0("mCPR model: ", mCPR_mod,"\nUnmet Need model: ",UN_mod))
  return(list(mCPR_mod=paste0("mod",mCPR_mod),UnmetNeed_mod=paste0("mod",UN_mod)))
}