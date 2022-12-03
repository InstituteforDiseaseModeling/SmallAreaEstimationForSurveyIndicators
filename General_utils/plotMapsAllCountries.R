plotMapsAllCountries<-function(PlotAllOfAfrica,
                               mapAdmin,
                               pathToFiguresForContinent,
                               Exampleselected_models,
                               pathToProjectDirectory,
                               RawDatafilelocation,
                               startYearMap,
                               endYearMap,
                               SAEDir){
  
  # Purpose of this function: This function plots the model output for all countries as a map of SSA.
  
  if(PlotAllOfAfrica){
        ## Need to define all countries to plot for shapefiles

  allCountryList<-list.dirs(paste0(RawDatafilelocation,"shapefiles/"),full.names=FALSE,recursive=FALSE)
  projectCountryList<-list.dirs(pathToProjectDirectory,full.names=FALSE,recursive=FALSE)

  for(modelIndex in 1 : length(Exampleselected_models$outcome)){
        
        for(k in startYearMap:endYearMap){
        
          # - create the name for the figure - #

          group_name_save<-paste0(unlist(strsplit(as.character(Exampleselected_models$subgroup[modelIndex]),":")),collapse="_")
          if(is.na(Exampleselected_models$subgroup[modelIndex])){
            group_name_save<-"ALL"
          }
          full_name<-paste0("Africa_",Exampleselected_models$outcome[modelIndex],"_",mapAdmin,"_",group_name_save,"_",k,".png")

          # - start the figure, same size as previous Africa maps - #
          png(paste0(pathToFiguresForContinent,full_name),
              height=6*1.15,width=6*1.15,res=400, unit="in")
          par(mar=c(0,0,1.5,0),mfrow=c(1,1))

          xmin <- -30.5
          xmax <- 50
          ymin <- -55
          ymax <- 35
          maxValue <-0.4
          
           for(countryIndex in 1:length(allCountryList)){
               country <- allCountryList[countryIndex]
           
               # Need to load the shapes piece for admin 0
               shapeFilePath <-paste0(RawDatafilelocation,"shapefiles/",country)
               layerS = paste0(country,"_l0_shapes")
               shape_data0<-readInShapefile(path=shapeFilePath,tmpName=layerS)
               shape0<-shape_data0$shape
               
               if(!(country %in% projectCountryList)){
                               
                               if(countryIndex==1){
                                 plot(shape0,border="black",xlim=c(xmin, xmax), ylim=c(ymin, ymax),col="#CCCCCC")

                               }else {
                                 plot(shape0,border="black",add=TRUE,xlim=c(xmin, xmax), ylim=c(ymin, ymax),col="#CCCCCC")
                               }
                 
               }else{
                 
                 # Need to define the country path
                 path_results <- paste0(pathToProjectDirectory,country,"/Results/")

                 # Need to load the model selection piece

                 res<-read_csv(paste0(path_results,"ModelSelection_",mapAdmin,".csv"))

                 # - this can be swapped for a matrix that forces different choices - #
                 selected_models<-group_by(res,outcome,subgroup)%>%summarize( selected_DIC=which(DIC==min(DIC)),
                                                                              selected_LCPO=which(LCPO==max(LCPO)),
                                                                              selected_WAIC=which(WAIC==min(WAIC)))%>%mutate(selected=selected_LCPO)
                 # Need to load the shapes piece

                 shape_data<-readInShapefile(path=paste0(RawDatafilelocation,"shapefiles/",country),tmpName=paste0(country,"_l",substring(mapAdmin,6,6),"_shapes"))
                 shape<-shape_data$shape

                 # - load in the relevant model output - #
                 FormattedData <- loadRData(paste0(path_results,"FormattedData_",country,".RDATA"))
                 
                 # - subset by subgroup - #
                 direct_data<-FormattedData
                 if(!is.na(selected_models$subgroup[modelIndex])){
                   direct_data<-filter(FormattedData,subgroup==selected_models$subgroup[modelIndex])
                 }
                 
                 
                 preds<-loadRData(paste0(path_results,selected_models$outcome[modelIndex],"_",mapAdmin,"_",group_name_save,"_model",selected_models$selected[modelIndex],".RDATA"))

                 # - add the predictions and intervals - #
                 direct_data$pred<-expit(preds$summary.fitted.values$`0.5quant`)

                 # - grab the predictions - #
                 # plotvar2 = direct_data$pred[direct_data$year==k]
                 # this is problematic if there are multiple observations (and thus predictions) for the same year#
                 if(length(direct_data$pred[direct_data$year==k])>nrow(shape@data)){
                   
                   multiples<-length(direct_data$pred[direct_data$year==k])/nrow(shape@data)
                   grab<-seq(1,length(direct_data$pred[direct_data$year==k]),by=multiples)
                   
                   plotvar2 = direct_data$pred[direct_data$year==k][grab]
                 }else plotvar2 = direct_data$pred[direct_data$year==k]
                 
                 
                 brks=seq(0,maxValue,length=11)
                 nclr<-length(brks)-1

                 # - assign colors to ranges - #
                 plotclr<-brewer.pal(nclr,"RdYlBu")
                 colornum<-findInterval(plotvar2, brks, all.inside=T)
                 colcode<-plotclr[colornum]
                 #
                 # - not the most robust solution, but that is the only indicator I can think of that would flip the blue to red - #
                 

                 
                 if(Exampleselected_models$outcome[modelIndex]=="STD"){
                   
                   # - grab the predictions - #
                   plotvar2 = -direct_data$pred[direct_data$year==k]
                   brks=seq(-maxValue,0,length=11)
                   nclr<-length(brks)-1
                   
                   plotclr<-brewer.pal(nclr,"RdYlBu")
                   colornum<-findInterval(plotvar2, brks, all.inside=T)
                   colcode<-plotclr[colornum]
                   
                   
                   color.legend(-22,-35,-16,-25, rect.col = plotclr,gradient="y",
                                legend=paste0(seq(maxValue,0,length=3)*100,"%"),
                                align="rb",cex=1.4)
                   
                 } else if (Exampleselected_models$outcome[modelIndex]=="SoreUlcer"){
                   
                   # - grab the predictions - #
                   plotvar2 = -direct_data$pred[direct_data$year==k]
                   brks=seq(-maxValue,0,length=11)
                   nclr<-length(brks)-1
                   
                   plotclr<-brewer.pal(nclr,"RdYlBu")
                   colornum<-findInterval(plotvar2, brks, all.inside=T)
                   colcode<-plotclr[colornum]
                   
                   
                   color.legend(-22,-35,-16,-25, rect.col = plotclr,gradient="y",
                                legend=paste0(seq(maxValue,0,length=3)*100,"%"),
                                align="rb",cex=1.4)
                   
                 } else if (Exampleselected_models$outcome[modelIndex]=="Discharge"){
                   
                   # - grab the predictions - #
                   plotvar2 = -direct_data$pred[direct_data$year==k]
                   brks=seq(-maxValue,0,length=11)
                   nclr<-length(brks)-1
                   
                   plotclr<-brewer.pal(nclr,"RdYlBu")
                   colornum<-findInterval(plotvar2, brks, all.inside=T)
                   colcode<-plotclr[colornum]
                   
                   
                   color.legend(-22,-35,-16,-25, rect.col = plotclr,gradient="y",
                                legend=paste0(seq(maxValue,0,length=3)*100,"%"),
                                align="rb",cex=1.4)
                   
                 } else {
                   color.legend(-22,-35,-16,-25, rect.col = plotclr,gradient="y",
                                legend=paste0(seq(0,maxValue,length=3)*100,"%"),
                                align="rb",cex=1.4)
                 }

                 plot(shape,border="black",lwd=0.3,col=colcode,add=TRUE)
                 plot(shape0,border="black",lwd=1,add=TRUE)
           }
           }
          
          dev.off()
        }
    }
  }
}