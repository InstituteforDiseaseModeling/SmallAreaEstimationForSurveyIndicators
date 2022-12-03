#########

## a function for plotting the maps in parallel


plotMapsParallel_ggplot<-function(admin_level,path_results,figure_path,FormattedData,selected_models,shape,plotting_limit,legend_location="right",ggplot_maps,PlotMaps){
  
  # Purpose of this function: This function plots the country maps in parallel but using ggplot.
  
  
  if(PlotMaps){
    
    if(ggplot_maps){
  shape@data$id<-rownames(shape@data)
  shape_points<-fortify(shape,region="id")
    
  plot_one_map<-function(admin_level,path_results,figure_path,FormattedData,selected_models,shape,ind,plotting_limit,legend_location){

    # ind<-1
    # - subset by subgroup - #
    direct_data<-FormattedData
    if(!is.na(selected_models$subgroup[ind])){
      direct_data<-filter(FormattedData,subgroup==selected_models$subgroup[ind])
    }
    
    # - load in the relevant model output - #
    group_name_save<-paste0(unlist(strsplit(as.character(selected_models$subgroup[ind]),":")),collapse="_")
    if(is.na(selected_models$subgroup[ind])){
      group_name_save<-"ALL"
    }
    preds<-loadRData(paste0(path_results,selected_models$outcome[ind],"_",admin_level,"_",group_name_save,"_model",selected_models$selected[ind],".RDATA"))
    
    # - add the predictions and intervals - #
    direct_data$pred<-expit(preds$summary.fitted.values$`0.5quant`)
    
    # - find limits - #
    minYear<-min(direct_data$year)
    maxYear<-max(direct_data$year)
    
    for(k in minYear:maxYear){
      # k<-2004
      # - create the path - #
      full_name<-paste0(selected_models$outcome[ind],"_",admin_level,"_",group_name_save,"_",k,"_model",selected_models$selected[ind],".png")
      
      # - start the figure - #
      png(paste0(figure_path,full_name),
          height=6*1.15,width=6*1.15,res=400, unit="in")
      # par(mar=c(0,0,1.5,0),mfrow=c(1,1))
      
      # - grab the predictions - #
      # this is problematic if there are multiple observations (and thus predictions) for the same year#
      if(length(direct_data$pred[direct_data$year==k])>nrow(shape@data)){
        
        multiples<-length(direct_data$pred[direct_data$year==k])/nrow(shape@data)
        grab<-seq(1,length(direct_data$pred[direct_data$year==k]),by=multiples)
        
      shape@data$plotvar<- direct_data$pred[direct_data$year==k][grab]
      }else shape@data$plotvar<- direct_data$pred[direct_data$year==k]
      
      
      shape_df<-left_join(shape_points,shape@data,by="id")
      
      # this is so the values that are larger do not show up as grey in the figures #
      shape_df<-shape_df%>%mutate(plotvar=ifelse(plotvar>plotting_limit,plotting_limit,plotvar))
      
      # - not the most robust solution, but that is the only indicator I can think of that would flip the blue to red - #
      if(selected_models$outcome[ind]=="unmet_need"){
       map_to_save<- ggplot(shape_df)+
          geom_polygon(aes(long,lat,group=group,fill=plotvar*100),color="black")+
          coord_equal()+
          scale_fill_gradient2_tableau(palette = "Red-Blue Diverging",trans="reverse",limits=c(plotting_limit,0)*100)+
          labs(x="Longitude",
               y="Latitude",
               fill="")+ theme(legend.position=legend_location)
        
      }else
        map_to_save<-  ggplot(shape_df)+
        geom_polygon(aes(long,lat,group=group,fill=plotvar*100),color="black")+
        coord_equal()+
        scale_fill_gradient2_tableau(palette = "Red-Blue Diverging",limits=c(0,plotting_limit)*100)+
        labs(x="Longitude",
             y="Latitude",
             fill="")+ theme(legend.position=legend_location)
        
      print(map_to_save)
      dev.off()
      
      
      
    }
    
  }

  
  
  system.time({
    ncores = detectCores()-1
    cl = makeCluster(ncores,type="SOCK")
    registerDoSNOW(cl)
    simdat = foreach(i=1:nrow(selected_models),.packages=c("dplyr","ggplot2","ggthemes","mapdata","maps","ggmap"),.export=c("loadRData","expit"),.combine=rbind) %dopar%  plot_one_map(admin_level,path_results,figure_path,FormattedData,selected_models,shape,ind=i,plotting_limit,legend_location)
    
    stopCluster(cl)
  })
    }
    
    if(!ggplot_maps){
      
 
      
      plot_one_map<-function(admin_level,path_results,figure_path,FormattedData,selected_models,shape,ind){
        
        # ind<-6
        # - subset by subgroup - #
        direct_data<-FormattedData
        if(!is.na(selected_models$subgroup[ind])){
          direct_data<-filter(FormattedData,subgroup==selected_models$subgroup[ind])
        }
        
        # - load in the relevant model output - #
        group_name_save<-paste0(unlist(strsplit(as.character(selected_models$subgroup[ind]),":")),collapse="_")
        if(is.na(selected_models$subgroup[ind])){
          group_name_save<-"ALL"
        }
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
          
          # this is problematic if there are multiple observations (and thus predictions) for the same year#
          if(length(direct_data$pred[direct_data$year==k])>nrow(shape@data)){
            
            multiples<-length(direct_data$pred[direct_data$year==k])/nrow(shape@data)
            grab<-seq(1,length(direct_data$pred[direct_data$year==k]),by=multiples)
            
            plotvar2 = direct_data$pred[direct_data$year==k][grab]
          }else plotvar2 = direct_data$pred[direct_data$year==k]
          
          
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
          

          dev.off()
          
          
          
        }
        
      }
      
      system.time({
        ncores = detectCores()-1
        cl = makeCluster(ncores,type="SOCK")
        registerDoSNOW(cl)
        simdat = foreach(i=1:nrow(selected_models),.packages=c("dplyr","RColorBrewer","classInt","maptools"),.export=c("color.legend","loadRData","expit","brewer.pal","findInterval"),.combine=rbind) %dopar%  plot_one_map(admin_level,path_results,figure_path,FormattedData,selected_models,shape,ind=i)
        
        stopCluster(cl)
      })
    }
    
    
  
}
}