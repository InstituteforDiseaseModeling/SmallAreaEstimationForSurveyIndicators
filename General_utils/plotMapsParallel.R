#########

## a function for plotting the maps in parallel


plotMapsParallel<-function(admin_level,path_results,figure_path,FormattedData,selected_models,shape,plotting_limit,include_legend,PlotMaps){
  
  
  # Purpose of this function: This function plots the maps of countries with model estimates in parallel.  
  
  if(PlotMaps){
  xl<-max(coordinates(shape)[,1])-1
  yb<-min(coordinates(shape)[,2])+1.5
  xr<-max(coordinates(shape)[,1])+0.5
  yt<-min(coordinates(shape)[,2])-0.5
    
  plot_one_map<-function(admin_level,path_results,figure_path,FormattedData,selected_models,shape,ind,xl,yb,xr,yt,include_legend){

    # ind<-6
    # - subset by subgroup - #
    direct_data<-filter(FormattedData,subgroup==selected_models$subgroup[ind])
    
    # - load in the relevant model output - #
    group_name_save<-paste0(unlist(strsplit(as.character(selected_models$subgroup[ind]),":")),collapse="_")
    preds<-loadRData(paste0(path_results,selected_models$outcome[ind],"_",admin_level,"_",group_name_save,"_model",selected_models$selected[ind],".RDATA"))
    
    # - add the predictions and intervals - #
    direct_data$pred<-expit(preds$summary.fitted.values$`0.5quant`)
    
    # - find limits - #
    minYear<-min(direct_data$year)
    maxYear<-max(direct_data$year)
    
    for(k in minYear:maxYear){
      # k<-2013
      # - create the path - #
      full_name<-paste0(selected_models$outcome[ind],"_",admin_level,"_",group_name_save,"_",k,"_model",selected_models$selected[ind],".png")
      
      # - start the figure - #
      png(paste0(figure_path,full_name),
          height=6*1.15,width=6*1.15,res=400, unit="in")
      par(mar=c(0,0,1.5,0),mfrow=c(1,1))
      
      # - grab the predictions - #
      plotvar2 = direct_data$pred[direct_data$year==k]
      
      # - set breaks and color numbers - #
      brks=seq(0,plotting_limit,length=11)
      nclr<-length(brks)-1
      
      # - assign colors to ranges - #
      plotclr<-brewer.pal(nclr,"RdYlBu")
      colornum<-findInterval(plotvar2, brks, all.inside=T)
      colcode<-plotclr[colornum]
      
      # - not the most robust solution, but that is the only indicator I can think of that would flip the blue to red - #
      if(selected_models$outcome[ind]=="unmet_need"){
        # - grab the predictions - #
        plotvar2 = -direct_data$pred[direct_data$year==k]
        brks=seq(-plotting_limit,0,length=11)
        nclr<-length(brks)-1
        
        plotclr<-brewer.pal(nclr,"RdYlBu")
        colornum<-findInterval(plotvar2, brks, all.inside=T)
        colcode<-plotclr[colornum]
      }
      
      
      # - plot map - #
      plot(shape,border="black",lwd=1,col=colcode)
      
      if(include_legend){

      if(selected_models$outcome[ind]=="unmet_need"){
      color.legend(xl,yb,xr,yt, 
                   rect.col = plotclr,gradient="y",
                   legend=paste0(seq(plotting_limit,0,length=3)*100,"%"),
                   align="rb",cex=1.4)
      }else
        color.legend(xl,yb,xr,yt, 
                     rect.col = plotclr,gradient="y",
                     legend=paste0(seq(0,plotting_limit,length=3)*100,"%"),
                     align="rb",cex=1.4)
      }
        
      dev.off()
      
      
      
    }
    
  }
  
  system.time({
    ncores = detectCores()-1
    cl = makeCluster(ncores,type="SOCK")
    registerDoSNOW(cl)
    simdat = foreach(i=1:nrow(selected_models),.packages=c("dplyr","RColorBrewer","classInt","maptools"),.export=c("color.legend","loadRData","expit","brewer.pal","findInterval"),.combine=rbind) %dopar%  plot_one_map(admin_level,path_results,figure_path,FormattedData,selected_models,shape,ind=i,xl,yb,xr,yt,include_legend)
    
    stopCluster(cl)
  })
  
  }
}