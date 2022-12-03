

plotTimeSeriesParallel<-function(admin_level,path_results,figure_path,FormattedData,selected_models,plotting_limit,PlotTimeSeries){
  
  # Purpose of this function: This function plots all of the time-series in parallel for each subnational area and demographic group.
  # It also saves the plots to the figure path.
  
  
if(PlotTimeSeries){
plot_one<-function(admin_level,path_results,figure_path,FormattedData,selected_models,ind){
  # ind<-1
  # - subset by subgroup - #
  direct_data<-FormattedData
  if(!is.na(selected_models$subgroup[ind])){
  direct_data<-filter(FormattedData,subgroup==selected_models$subgroup[ind])
  }
  
  # - set the outcome variable - #
  outcome_variable<-selected_models$outcome[ind]
  se_variable<-paste0("se.",selected_models$outcome[ind])
  direct_data$outcome<-unlist(direct_data[,outcome_variable])
  names(direct_data$outcome)<-"outcome"
  direct_data$SE<-unlist(direct_data[,se_variable])
  names(direct_data$SE)<-"SE"
  
  # - create the confidence intervals for direst estimates - #
  direct_data<-direct_data%>%mutate(direct_upper=outcome+qnorm(0.975)*SE,
                                    direct_lower=outcome-qnorm(0.975)*SE)
  
  # - load in the relevant model output - #
  group_name_save<-paste0(unlist(strsplit(as.character(selected_models$subgroup[ind]),":")),collapse="_")
  if(is.na(selected_models$subgroup[ind])){
    group_name_save<-"ALL"
  }
  preds<-loadRData(paste0(path_results,selected_models$outcome[ind],"_",admin_level,"_",group_name_save,"_model",selected_models$selected[ind],".RDATA"))
  
  # - add the predictions and intervals - #
  direct_data$pred<-expit(preds$summary.fitted.values$`0.5quant`)
  direct_data$pred_upper<-expit(preds$summary.fitted.values$`0.975quant`)
  direct_data$pred_lower<-expit(preds$summary.fitted.values$`0.025quant`)
  
  # - which states to loop through - #
  states<-unique(direct_data$state)
  
  # -- looping through the states -- #
  for(j in 1:length(states)){
    
    state<-states[j]
    
    if (!is.na(state)){
      
      out <- tryCatch(
        {
          nameForFile <- gsub(":","_",state)
          nameForFile <- gsub(" ","", nameForFile)
          nameForFile <- str_replace_all(nameForFile, "[^[:alnum:]]", "")
          nameForFile <- iconv(nameForFile, from = 'UTF-8', to = 'ASCII//TRANSLIT')
          
          full_name<-paste0(selected_models$outcome[ind],"_",admin_level,"_",group_name_save,"_",nameForFile,"_model",selected_models$selected[ind],".png")
          
          
          # - starting the figure - #
          png(paste0(figure_path,full_name),
              height=6*1.15,width=8*1.15,res=400, unit="in")
          par(mar=c(4,4,1,1))
          
          # - subsetting to the data for the appropriate state - #
          plot_dat<-filter(direct_data,state==states[j])
          
          # - empty plot - #    
          with(plot_dat,plot(year,outcome,pch=NA,ylim=c(0,plotting_limit),cex.lab=1.3,ylab="Rate",xlab="Year"))  
          
          # - find limits - #
          minYear<-min(plot_dat$year)
          maxYear<-max(plot_dat$year)
          
          if(sum(names(plot_dat)=="survey_id")>0){
            # - add prediction uncertainty - #
            polygon(c(minYear:maxYear,maxYear:minYear),
                    c(plot_dat$pred_lower[is.na(plot_dat$survey_id)],
                      rev(plot_dat$pred_upper[is.na(plot_dat$survey_id)])),
                    col=addTrans("grey80",200),border=NA)
            
            # - add predictions and direct estimtaes - #
            with(filter(plot_dat,is.na(survey_id)),points(year,pred,type="l",lty=1,lwd=2,cex=1.3))
            
            with(plot_dat,points(year,outcome,pch=19,cex=1.3,col=addTrans(as.numeric(survey_id),200)))  
            
            # - add designed based CIs - #
            segments(plot_dat$year,
                     (plot_dat$direct_lower),
                     plot_dat$year,
                     (plot_dat$direct_upper),
                     # col=1,
                     lwd=1.3,
                     col=addTrans(as.numeric(plot_dat$survey_id),200))
            
            legend(minYear,plotting_limit,c("DHS","Modeled mCPR","95% CI"),
                   lty=1,lwd=c(1,2,10),pch=c(19,NA,NA),col=c(1,1,addTrans("grey80",250)))
            
          }
          
          if(sum(names(plot_dat)=="survey_id")==0){
          # - add prediction uncertainty - #
          polygon(c(plot_dat$year,rev(plot_dat$year)),
                  c(plot_dat$pred_lower,
                    rev(plot_dat$pred_upper)),
                  col=addTrans("grey80",200),border=NA)
            
            # polygon(c(minYear:maxYear,maxYear:minYear),
            #         c(plot_dat$pred_lower,
            #           rev(plot_dat$pred_upper)),
            #         col=addTrans("grey80",200),border=NA)
          
          # - add predictions and direct estimtaes - #
          with(plot_dat,points(year,pred,type="l",lty=1,lwd=2,cex=1.3))
          with(plot_dat,points(year,outcome,pch=19,cex=1.3))  
          
          # - add designed based CIs - #
          segments(plot_dat$year,
                   (plot_dat$direct_lower),
                   plot_dat$year,
                   (plot_dat$direct_upper),
                   col=1,lwd=1.3)
          
          legend(minYear,plotting_limit,c("DHS","Modeled mCPR","95% CI"),
                 lty=1,lwd=c(1,2,10),pch=c(19,NA,NA),col=c(1,1,addTrans("grey80",250)))
          }
          
          dev.off()
          # 
        },
        error=function(cond) {
          message(paste0("There is something wrong with the admin ", state))
          message(cond)
          dev.off()
          # Choose a return value in case of error
          return(NA)
        },
        warning=function(cond) {
          message(cond)
          # Choose a return value in case of warning
          return(NULL)
        }
      )
      
    }
    
    
  }
  
  
}



system.time({
  ncores = detectCores()-1
  cl = makeCluster(ncores,type="SOCK")
  registerDoSNOW(cl)
  simdat = foreach(i=1:nrow(selected_models),.packages=c("dplyr","stringr"),.export=c("expit","addTrans","loadRData"),.combine=rbind) %dopar%  plot_one(admin_level,path_results,figure_path,FormattedData,selected_models,ind=i)

  stopCluster(cl)
})
}
  
}