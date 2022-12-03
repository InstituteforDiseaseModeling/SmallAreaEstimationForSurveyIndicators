fitAllModelsParallel<-function(model_data,path_results,SubGroup,outcome,adjacency_matrix,admin_level,cohortModel,FitModels){

  
  # Purpose of this function: This function builds the models, fits them, computes the model selection criteria, and outputs 
  # an intermediate file on the model selection.
  
if(cohortModel){SubGroup=NA}  
  
if(FitModels){
   
   
   models2beFit<-expand.grid(model=1:4,outcome=outcome,subgroup=SubGroup)
   
   # if there are only two unique surveys, do not considered RW2 - #
   # you will need to consider how to code this for the survey interaction 1:12 models #
   # however, less likely to happen there as you should have more that 2 #
   if(sum(!is.na((unique(model_data$survey))))<3){
      models2beFit<-expand.grid(model=1:2,outcome=outcome,subgroup=SubGroup)
   }
   
    # -- If there is a survey ID, expand model choices -- #
  if(sum(names(model_data)=="survey_id")>0){
    models2beFit<-expand.grid(model=1:12,outcome=outcome,subgroup=NA)
    
  }
  
 do.one<-function(data,adjacency_matrix,admin_level,path_results,ind){
   # ind<-1
   data<-model_data
   
   if(is.na(models2beFit$subgroup[ind])){
   fit_data<-data
   }else fit_data<-data%>%filter(subgroup==models2beFit$subgroup[ind])
   # mean(fit_data$modern_method,na.rm=T)
   
   # needs to grab the model, outcome and subgroup
   
   model<-models2beFit$model[ind]
   outcome_variable<-paste0("logit_",models2beFit$outcome[ind])
   var_variable<-paste0("var_logit_",models2beFit$outcome[ind])
   
   fit_data$outcome<-unlist(fit_data[,outcome_variable])
   names(fit_data$outcome)<-"outcome"
   fit_data$prec<-unlist(1/fit_data[,var_variable])
   names(fit_data$prec)<-"prec"
   fit_data$preds<-0
   
   
   # -- set the hyper priors -- #
   prior.iid = c(0.5,0.008)
   prior.besag = c(0.001,0.001)
   initial.iid = 1
   initial.besag = 1
   
   # -- set the models (more if we have survey effects) -- #
   
   if(model==1){
     model_formula  <- outcome ~ f(dist.id, model="bym", graph=adjacency_matrix) +  # state BYM effect
     f(period.id, model="rw1") +  # random walk 2
     f(period.id2, model="iid") +  # iid time
     f(period.id3, model="rw1", replicate=dist.id) # state X time
   }
   
   if(model==2){
     model_formula <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
     f(period.id, model="rw1") +  # random walk 2
     f(period.id2, model="iid") +  # iid time
     f(period.id3, model="rw1", replicate=dist.id) # state X time
   }
   
   if(model==3){
     model_formula <- outcome ~ f(dist.id, model="bym", graph=adjacency_matrix) +  # state BYM effect
     f(period.id, model="rw2") +  # random walk 2
     f(period.id2, model="iid") +  # iid time
     f(period.id3, model="rw2", replicate=dist.id) # state X time
   }
   
   if(model==4){
     model_formula  <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
     f(period.id, model="rw2") +  # random walk 2
     f(period.id2, model="iid") +  # iid time
     f(period.id3, model="rw2", replicate=dist.id) # state X time
   }

   # -- With survey random effects -- #
   # - model 5 - #
   if(model==5){
     model_formula  <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
     f(period.id, model="rw1") +  # random walk 2
     f(period.id2, model="iid") +  # iid time
     f(period.id3, model="rw1", replicate=dist.id) + # state X time
     f(survey_id, model="iid")   # iid survey
   }
   # - model 6 - #
   if(model==6){
     model_formula <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
     f(period.id, model="rw2") +  # random walk 2
     f(period.id2, model="iid") +  # iid time
     f(period.id3, model="rw2", replicate=dist.id) + # state X time
     f(survey_id, model="iid")   # iid survey
   }
   # - model 7 - #
   if(model==7){
     model_formula  <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
     f(period.id, model="rw1") +  # random walk 2
     f(period.id2, model="iid") +  # iid time
     f(period.id3, model="rw1", replicate=dist.id) + # state X time
     f(survey_id, model="iid") +  # iid survey
     f(survey_id2, model="iid",replicate=dist.id)   # iid survey X state
   }
  # - model 8 - #
   if(model==8){
     model_formula  <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
     f(period.id, model="rw2") +  # random walk 2
     f(period.id2, model="iid") +  # iid time
     f(period.id3, model="rw2", replicate=dist.id) + # state X time
     f(survey_id, model="iid") +  # iid survey
     f(survey_id2, model="iid",replicate=dist.id)  # iid survey X state
   }
  # - model 9 - #
  if(model==9){
    model_formula <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
    f(period.id, model="rw1") +  # random walk 2
    f(period.id2, model="iid") +  # iid time
    f(period.id3, model="rw1", replicate=dist.id) + # state X time
    f(survey_id, model="iid") +  # iid survey
    f(survey_id2, model="iid",replicate=period.id)   # iid survey X time
  }
  # - model 10 - #
  if(model==10){
    model_formula  <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
    f(period.id, model="rw2") +  # random walk 2
    f(period.id2, model="iid") +  # iid time
    f(period.id3, model="rw2", replicate=dist.id) + # state X time
    f(survey_id, model="iid") +  # iid survey
    f(survey_id2, model="iid",replicate=period.id)  # iid survey X time
  }
  # - model 11 - #
  if(model==11){
    model_formula  <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
    f(period.id, model="rw1") +  # random walk 2
    f(period.id2, model="iid") +  # iid time
    f(period.id3, model="rw1", replicate=dist.id) + # state X time
    f(survey_id, model="iid") +  # iid survey
    f(survey_id2, model="iid",replicate=period.id) +  # iid survey X time
    f(survey_id3, model="iid",replicate=period.id)  # iid survey X time
  }
  # - model 12 - #
  if(model==12){
    model_formula <- outcome ~ f(dist.id, model="bym2", graph=adjacency_matrix) +  # state scaled BYM effect
    f(period.id, model="rw2") +  # random walk 2
    f(period.id2, model="iid") +  # iid time
    f(period.id3, model="rw2", replicate=dist.id) + # state X time
    f(survey_id, model="iid") +  # iid survey
    f(survey_id2, model="iid",replicate=period.id) + # iid survey X time
    f(survey_id3, model="iid",replicate=period.id)  # iid survey X time
     
  }   
     
     
# -- fit the models -- #

    mod <- inla(model_formula, 
                 family = "gaussian", 
                 data =fit_data, 
                 control.predictor=list(compute=TRUE),
                 control.compute=list(cpo=TRUE,dic=TRUE,waic=T,config=T),
                 control.family=list(hyper=list(prec=list(initial=log(1),fixed=TRUE))),
                 scale=prec,verbose=F)

   
   group_name_save<-models2beFit$subgroup[ind]
   if(models2beFit$subgroup[ind]!="ALL" & !is.na(models2beFit$subgroup[ind])){
   group_name_save<-paste0(unlist(strsplit(as.character(models2beFit$subgroup[ind]),":")),collapse="_")
   }
   if(is.na(models2beFit$subgroup[ind])){
     group_name_save<-"ALL"
   }
   
   
   save(mod,file=paste0(path_results,models2beFit$outcome[ind],"_",admin_level,"_",group_name_save,"_model",model,".RDATA"))
   
   c(mod$dic$dic,sum(log(mod$cpo$cpo),na.rm=T),mod$waic$waic,max(expit(mod$summary.fitted.values$`0.5quant`)),max(expit(mod$summary.fitted.values$`0.975quant`)))
 }


#############################################
  system.time({
    ncores = detectCores()-1
    cl = makeCluster(ncores,type="SOCK")
    registerDoSNOW(cl)
    simdat = foreach(i = 1:nrow(models2beFit),.packages=c("INLA","dplyr"),.export=c("expit"),.combine=rbind) %dopar%  do.one(data=model_data,adjacency_matrix,admin_level,path_results,ind=i)
    
    stopCluster(cl)
  })
  

models2beFit$DIC<-simdat[,1]
models2beFit$LCPO<-simdat[,2]
models2beFit$WAIC<-simdat[,3]
models2beFit$maxPred<-simdat[,4]
models2beFit$maxUpper<-simdat[,5]

write_csv(models2beFit,paste0(path_results,"ModelSelection_",admin_level,".csv"))
}

}
