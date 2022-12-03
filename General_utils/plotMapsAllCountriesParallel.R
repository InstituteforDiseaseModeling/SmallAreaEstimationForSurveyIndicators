## This does not work yet.

plotMapsAllCountriesParallel<-function(PlotAllOfAfrica,
                               admin_level,
                               figure_path,
                               selected_models,
                               pathToProjectDirectory,
                               RawDatafilelocation,
                               startYearMap,
                               endYearMap,
                               SAEDir){

  # Purpose of this function: This function plots the model output for all countries as a map of SSA in parallel. 

  
        plot_one_continent<-function(admin_level,figure_path,Exampleselected_models,ind,pathToProjectDirectory,
                                     startYearMap,endYearMap,RawDatafilelocation,SAEDir){
        #plot_one_continent<-function(){
            
          
          #disp("Made it in the function")}
          # 
          ## Need to define all countries to plot for shapefiles

        allCountryList<-list.dirs(paste0(RawDatafilelocation,"shapefiles/"),full.names=FALSE,recursive=FALSE)
        projectCountryList<-list.dirs(pathToProjectDirectory,full.names=FALSE,recursive=FALSE)

        summary(allCountryList)
        
        #for(k in startYearMap:endYearMap){
        for(k in 1:1){
          # - create the name for the figure - #

          group_name_save<-paste0(unlist(strsplit(as.character(Exampleselected_models$subgroup[ind]),":")),collapse="_")
          full_name<-paste0("Africa_",Exampleselected_models$outcome[ind],"_",admin_level,"_",group_name_save,"_",k,".png")

          # - start the figure, same size as previous Africa maps - #
          png(paste0(figure_path,full_name),
              height=6*1.15,width=6*1.15,res=400, unit="in")
          par(mar=c(0,0,1.5,0),mfrow=c(1,1))

          xmin <- -30.5
          xmax <- 50
          ymin <- -55
          ymax <- 35
          
           for(countryIndex in 1:length(allCountryList)){
               country <- allCountryList[countryIndex]
           
               # Need to load the shapes piece for admin 0
               
               #source(paste0(SAEDir,"Code/General_utils/readInShapefile.R"))
               
               shape<- shapefile(paste0(RawDatafilelocation,"shapefiles/",country,"/",country,"_l0_shapes"))
               
               # adding a row number to the shape2 object, will be handy for plotting later on
               shape@data$row_num<-1:nrow(shape@data)
               
               
               adminName_key<-shape@data[,c("row_num","dot_name")]
               colnames(adminName_key)[colnames(adminName_key)=="dot_name"] <- "state"
               
               nb.r <- poly2nb(shape, queen=F)
               mat <- nb2mat(nb.r, style="B",zero.policy=TRUE) 
               
               #shape_data<-readInShapefile(paste0(RawDatafilelocation,"shapefiles/",country,"/",country,"_l0_shapes"))
               shape0<-shape$shape
               
               if(!(country %in% projectCountryList)){
                               
                               #if(countryIndex==1){
                              #   plot(shape0,border="black",xlim=c(xmin, xmax), ylim=c(ymin, ymax),col="#CCCCCC")
                               
                               #}else {
                              #   plot(shape0,border="black",add=TRUE,xlim=c(xmin, xmax), ylim=c(ymin, ymax),col="#CCCCCC")
                              # }
                 
               }else{
                 
                 # # Need to define the country path
                 # path_results <- paste0(pathToProjectDirectory,country,"/Results/")
                 # 
                 # # Need to load the model selection piece
                 # 
                 # res<-read_csv(paste0(path_results,"ModelSelection_",admin_level,".csv"))
                 # 
                 # # - this can be swapped for a matrix that forces different choices - #
                 # selected_models<-group_by(res,outcome,subgroup)%>%summarize( selected_DIC=which(DIC==min(DIC)),
                 #                                                              selected_LCPO=which(LCPO==max(LCPO)),
                 #                                                              selected_WAIC=which(WAIC==min(WAIC)))%>%mutate(selected=selected_LCPO)
                 # # Need to load the shapes piece
                 # 
                 # shape_data<-readInShapefile(path=paste0(RawDatafilelocation,"shapefiles/",country,"/",country,"_l",substring(admin_level,6,6),"_shapes"))
                 # shape<-shape_data$shape
                 # 
                 # # - load in the relevant model output - #
                 # preds<-loadRData(paste0(path_results,selected_models$outcome[ind],"_",admin_level,"_",group_name_save,"_model",selected_models$selected[ind],".RDATA"))
                 # 
                 # # - grab the predictions - #
                 # plotvar2 = preds[preds$year==k]
                 # 
                 # brks=seq(0,0.5,length=11)
                 # nclr<-length(brks)-1
                 # 
                 # # - assign colors to ranges - #
                 # plotclr<-brewer.pal(nclr,"RdYlBu")
                 # colornum<-findInterval(plotvar2, brks, all.inside=T)
                 # colcode<-plotclr[colornum]
                 # # 
                 # # - not the most robust solution, but that is the only indicator I can think of that would flip the blue to red - #
                 # if(selected_models$outcome[ind]=="unmet_need"){
                 #   #           # - grab the predictions - #
                 #   plotvar2 = -preds[preds$year==k]
                 #   brks=seq(-0.5,0,length=11)
                 #   nclr<-length(brks)-1
                 #   # 
                 #   plotclr<-brewer.pal(nclr,"RdYlBu")
                 #   colornum<-findInterval(plotvar2, brks, all.inside=T)
                 #   colcode<-plotclr[colornum]
                 # }
                 # 
                 # plot(shape,border="black",lwd=0.3,col=colcode,add=TRUE)
                 # plot(shape0,border="black",lwd=1,add=TRUE)
           }
           }
          
          dev.off()
        }
        
        }
        
      system.time({
        ncores = detectCores()-1
        cl = makeCluster(ncores,type="SOCK")
        registerDoSNOW(cl)
        #simdat = foreach(i=1:nrow(selected_models),.packages=c("dplyr","RColorBrewer","classInt","maptools"),.export=c("color.legend","loadRData","expit","brewer.pal","findInterval"),.combine=rbind) %dopar%  plot_one_continent(admin_level,path_results,figure_path,Exampleselected_models,ind=i,xl,yb,xr,yt,pathToProjectDirectory,allCountryList,projectCountryList,startYearMap,endYearMap,RawDatafilelocation)
        simdat = foreach(i=1:2,.packages=c("dplyr","RColorBrewer","classInt","maptools","raster","readr","rgeos","spdep"),.export=c("color.legend","loadRData","expit","brewer.pal","findInterval","poly2nb","nb2mat"),.combine=rbind) %dopar%  plot_one_continent(admin_level,figure_path,selected_models,ind=i,pathToProjectDirectory,
                                                                                                                                                                                                                                startYearMap,endYearMap,RawDatafilelocation,SAEDir)
        stopCluster(cl)
      })
    }
