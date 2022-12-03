
DHS_ExtractionWithGPS<-function(RawDatafilelocation,gps.file,shape,survey.id,
                                survey.file.ir,survey.file.ch,
                                strata_vars,id_var,country,surveyYear,pathToIntermediateDataFiles){

# Purpose of this function: This function extracts the DHS data, overlays with the GPS data, and computes the direct estimates
  
##############################################
# -- Read in the GPS points and shapefile -- #
##############################################
# using quiet() with this function does not work.
  # paste0(RawDatafilelocation,"DHS/")

pts<- readOGR(paste0(RawDatafilelocation, gps.file), layer = gps.file)

#pts<- readOGR(paste0(paste0(RawDatafilelocation,"DHS/"), gps.file), layer = gps.file)
##### IS THIS NECESSARY?
# adding a row number to the shape object, will be handy for plotting later on
shape@data$row_num<-1:nrow(shape@data)

# Assign the cluster locations to most accurate shapefile state names
x<-over(SpatialPoints(coordinates(pts),proj4string = shape@proj4string), shape)

# is this necessary?
#GPS_Cluster_key<-data.frame(v001=pts@data[,c("DHSCLUST")],state=x$dot_name,row_num=x$row_num)
GPS_Cluster_key<-data.frame(v001=as.numeric(pts@data[,c("DHSCLUST")]),state=x$dot_name,row_num=x$row_num)

##############################################
# -- read individual recode data from DHS -- #
##############################################
#system.time({
#paste0(RawDatafilelocation,"DHS/")
dhs<-read_dta(paste0(RawDatafilelocation,survey.file.ir,"DT/",survey.file.ir,"FL.DTA"))
dhs_ch<-read_dta(paste0(RawDatafilelocation,survey.file.ch,"DT/",survey.file.ch,"FL.DTA"))
# dhs<-read_dta(paste0( paste0(RawDatafilelocation,"DHS/"),survey.file.ir,"DT/",survey.file.ir,"FL.DTA"))
# dhs_ch<-read_dta(paste0( paste0(RawDatafilelocation,"DHS/"),survey.file.ch,"DT/",survey.file.ch,"FL.DTA"))
#})
#dim(dhs)
# -- merge the key in with the dhs data -- #
dhs<-dhs%>%left_join(GPS_Cluster_key)
dhs_ch<-dhs_ch%>%left_join(GPS_Cluster_key)
# should still have the same number of rows
#dim(dhs)

###############################
# -- start analyzing survey --#
###############################

# - first checking to see if "awfctt" variable is in the dataset
# - This is the all women factor, if it is not there we add it
# - it will only be in surveys that ONLY survey married women
if(!("awfctt"%in%names(dhs))){dhs$awfactt<-100}

dhs<-dhs%>%mutate(wt=v005/1000000, # have to scale the weight
                  year_cmc=floor((v008-1)/12)+1900, # finding the year based on Century Month Codes
                  month_cmc=v008-(year_cmc-1900)*12, # finding the month
                  year=year_cmc+month_cmc/12, # grabbing year
                  country_code=substr(v000,start=1,stop=2), # finding the country code
                  recode=substr(v000,3,3), # which recode manual to look at
                  survey_year=surveyYear
)

dhs_ch<-dhs_ch%>%mutate(wt=v005/1000000, # have to scale the weight
                  year_cmc=floor((v008-1)/12)+1900, # finding the year based on Century Month Codes
                  month_cmc=v008-(year_cmc-1900)*12, # finding the month
                  year=year_cmc+month_cmc/12, # grabbing year
                  country_code=substr(v000,start=1,stop=2), # finding the country code
                  recode=substr(v000,3,3), # which recode manual to look at
                  survey_year=surveyYear
)


##########################################
# -- Add indicators based on  -- #
##########################################
dhs<-add_DHS_indicators(dhs,dhs_ch,survey.id)



##########################################
# -- Set up the survey design object -- #
##########################################

# -- create strata variable -- #
#strata<-unique(dhs[,strata_vars])
#strata$strata<-1:nrow(strata)
#dhs<-dhs%>%left_join(strata)

#my.svydesign <- svydesign(id= ~v001,
#                          strata=~strata,nest=T, 
#                          weights= ~wt, data=dhs)

my.svydesign <- svydesign(id= as.formula(paste0("~",id_var)),
                          strata=as.formula(paste0("~",strata_vars)),nest=T, 
                          weights= ~wt, data=dhs)


########################################################
## Compute direct estimates and SEs  ###################
########################################################

final <- compute_direct_estimates(my.svydesign,indicators,sub_groups=unique(dhs$subgroup),states=as.character(shape@data$dot_name),dhs)
final$year<-surveyYear
final$recode<-dhs$recode[1]
final$country<-country
final$survey<-paste0("DHS_",surveyYear)

write_excel_csv(final, paste0(pathToIntermediateDataFiles,"Processed_",country,surveyYear,"_",mapAdmin,".csv"))

}