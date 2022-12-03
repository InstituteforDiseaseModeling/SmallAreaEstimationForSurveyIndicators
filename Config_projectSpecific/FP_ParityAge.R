# -- Project Config file -- #

# Author: Joshua Proctor
# Date: 29 Feb 2021

# Project Name:
ProjectName<-"FP_ParityAge"

# Country:
country<-"ALL"

# Administrative Level (admin1 or admin2)
mapAdmin<-"admin1"

# Prediction Year:
predYear <-2025
startYear<-1990

startYearMap    <- 2015
endYearMap      <- 2025

# sub-groups (age, parity, etc.).  Note, these names must match the sub-group names in
# add_DHS_indicator, add_MICS_indicator, etc.

# these must match the indicators created in add_DHS_indicators.R (project-specific)
indicators<-c("modern_method","unmet_need","traditional_method")


# - set flags for processing data, fitting models, and plotting - #

ProcessData <- T#as.logical(TRUE)
FitModels <- T#as.logical(TRUE)
PlotMaps <- T#as.logical(TRUE)
PlotTimeSeries <- T#as.logical(TRUE)
ggplot_maps <- F#as.logical(TRUE)
PlotAllOfAfrica<-T#as.logical(F)
PlotOPCountries<-as.logical(TRUE)

# - optional to set if you are using ggplot_maps, defaults to "right" - #
legend_location<-"right" # options "right", "left", "top", "bottom", "" (will give none).