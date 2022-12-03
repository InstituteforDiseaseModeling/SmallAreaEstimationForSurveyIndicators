plotMaps<-function(admin_level,path_results,figure_path,FormattedData,selected_models){
  
  # Purpose of this function: This function plots the maps and saves to the figure path.
  
  for(i in 1:nrow(selected_models)){

    # - subset by subgroup - #
    direct_data<-filter(FormattedData,subgroup==selected_models$subgroup[i])
    
    # - load in the relevant model output - #
    group_name_save<-paste0(unlist(strsplit(as.character(selected_models$subgroup[i]),":")),collapse="_")
    preds<-loadRData(paste0(path_results,selected_models$outcome[i],"_",admin_level,"_",group_name_save,"_model",selected_models$selected[i],".RDATA"))
    
    # - add the predictions and intervals - #
    direct_data$pred<-expit(preds$summary.fitted.values$`0.5quant`)
    
    # - find limits - #
    minYear<-min(direct_data$year)
    maxYear<-max(direct_data$year)
    
    for(k in minYear:maxYear){
      
      # - create the path - #
      full_name<-paste0(selected_models$outcome[i],"_",admin_level,"_",group_name_save,"_",k,"_model",selected_models$selected[i],".png")
      
      # - start the figure - #
      png(paste0(figure_path,full_name),
          height=6*1.15,width=6*1.15,res=400, unit="in")
      par(mar=c(0,0,1.5,0),mfrow=c(1,1))
      
      # - grab the predictions - #
      plotvar2 = direct_data$pred[direct_data$year==k]
      
      # - set breaks and color numbers - #
      brks=seq(0,0.3,length=11)
      nclr<-length(brks)-1
      
      # - assign colors to ranges - #
      plotclr<-brewer.pal(nclr,"RdYlBu")
      colornum<-findInterval(plotvar2, brks, all.inside=T)
      colcode<-plotclr[colornum]
      
      # - not the most robust solution, but that is the only indicator I can think of that would flip the blue to red - #
      if(selected_models$outcome[i]=="unmet_need"){
        brks=seq(-0.3,0,length=11)
        nclr<-length(brks)-1
        
        plotclr<-brewer.pal(nclr,"RdYlBu")
        colornum<-findInterval(plotvar2, brks, all.inside=T)
        colcode<-plotclr[colornum]
      }
      
      
      # - plot map - #
      plot(shape,border="black",lwd=1,col=colcode)

      # - create legend - #  
      # # - commenting out for now b/c it isn't in the right place for most countries - #
      # color.legend(-12.75,15.5,-11.75,17, rect.col = plotclr,gradient="y",
      #              legend=paste0(seq(0,0.3,length=3)*100,"%"),
      #              align="rb",cex=1.4)
      dev.off()
      
      
      
    }
  
  }
  
}