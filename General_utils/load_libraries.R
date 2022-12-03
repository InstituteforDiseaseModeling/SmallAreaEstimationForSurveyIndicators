###############################################
## Libraries ###
################
# read packages
library(foreign);library(survey);library(INLA);library(ipumsr)
library(dplyr);library(haven);library(readr)
options(survey.lonely.psu="adjust")

# -- packages -- #
library(rgeos); library(maptools); library(plotrix); library(raster);library(sp)
library(classInt); library(RColorBrewer); 
library(grDevices); library(rgdal)
library(mapproj); library(lubridate); library(grid)
library(gridExtra);library(spdep)
library(pracma);library(stringr);library(ddpcr)

library(doSNOW)
library(foreach)
library(parallel)
library(doParallel)
library(readxl)

library(ggmap)
library(maps)
library(ggplot2)
library(ggthemes)
library(mapdata)