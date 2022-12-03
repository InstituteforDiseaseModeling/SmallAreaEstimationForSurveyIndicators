# -- Project Config file -- #

# Author: Josh
# Date: 26 March 2020

# Project Name:
ProjectName<-"FP_Age"

# Country:
country<-"ALL"      # This can either be "ALL", "Single Country name" or a list of countries, i.e., c("Benin","BurkinaFaso")

# Administrative Level (admin1 or admin2)
mapAdmin<-"admin1"

# Prediction Year:
predYear <-2025
startYear<-1990

# sub-groups (age, parity, etc.).  Note, these names must match the sub-group names in
# add_DHS_indicator, add_MICS_indicator, etc.

# these must match the indicators created in add_DHS_indicators.R (project-specific)
indicators<-c("modern_method","unmet_need","traditional_method")

# Boolean to process all of the raw survey data for the country.  An error is thrown if you flag 
# this false and it goes to look for those files.  

ProcessData <- as.logical(TRUE)

## Plotting All Africa or all countries.  

startYearMap    <- 2015
endYearMap      <- 2025

FitModels <- as.logical(TRUE)
PlotMaps <- as.logical(TRUE)
include_legend <- as.logical(FALSE)

PlotTimeSeries <- as.logical(TRUE)
ggplot_maps <- as.logical(FALSE) 
PlotAllOfAfrica<-as.logical(TRUE)

startYearMapDiff <-2020
endYearMapDiff<-2010
PlotDiffAllOfAfrica<-as.logical(FALSE)

PlotOPCountries<-as.logical(FALSE)
PlotDiffOPCountries<-as.logical(FALSE)