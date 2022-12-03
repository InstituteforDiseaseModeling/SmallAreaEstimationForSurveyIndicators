# SmallAreaEstimationForSurveyIndicators

There are multiple goals for this project and repository.  One aim was to develop a custom, but fairly automated R-based framework to estimate survey indicators using small area estimation techniques at the subnational and demographic subgroup scale.  Concurrently, we also aimed to provide novel contributions to the family planning (FP) scientific community by providing detailed estimates of FP indicators subnationally and by demographic subgroups.  This is a research tool that we are providing open source to go along with published research and web-based visualization of the results.  

## Links to the family planning research and dashboard visualization of these results.  

A subnational modeling approach for FP indicators in Nigeria using DHS, MICS, PMA, and NNHS cross-sectional survey data:

https://bmcpublichealth.biomedcentral.com/articles/10.1186/s12889-019-8043-z

A subnational modeling approach using the current form of this code-base for FP indicators across 26 countries in Sub-Saharan Africa:

https://www.medrxiv.org/content/10.1101/2021.03.03.21252829v1.full.pdf

The location of an interactive dashboard for visualizing the model results:

https://sfpet.bmgf.io/

## Data Availability

The framework separates the code from the rawdata and the output folders. The rawdata includes survey data from the demographic health survey (DHS) and shapefiles from GADM.  Thata data are publicly available and would need to be downloaded by each user. 

## Starting a new project

Starting a new project is fairly easy.  There is a master main file at the head of the code; this R script is an example of how to run the entire modeling pipeline and produce some plots of the outputs.  The current example *should* be executable for examples in the family planning space.  You need to set the working directory, where the raw data is located (after downloading the associated DHS and shapefile data), and modify the config_paths.R for your own setup.  There is also a line to define the project configuration file.  There are several example configuration files in the folder to start with.  I have provided a surveyCodeBook.xlsx that lists the DHS files that are included in this project and the corresponding stratification variables.  That file is located in the general utilities folder in the repository here; you may need to change the variable pathToMasterSurveyList in the Config_project.R depending on where you store that file.  

Creating a new configuration file requires two parts:  a configuration input file and adding project specific utils required for the framework.  At this point, there is only one required file called add_DHS_indicators.R in the project specific utils.  In this file, you, as a user, must translate the survey codes to the variable names that were exactly described in the configuration file.  This is for both the outcome survey indicators and the demographic subgroups.    

## Environment

The following is the current environment I'm using to run the framework. I plan to develop a docker and conda environment for the framework in the future.  

R version 3.6.1 (2019-07-05)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows >= 8 x64 (build 9200)

Matrix products: default

locale:
[1] LC_COLLATE=English_United States.1252  LC_CTYPE=English_United States.1252    LC_MONETARY=English_United States.1252
[4] LC_NUMERIC=C                           LC_TIME=English_United States.1252    

attached base packages:
[1] parallel  grid      stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] mapdata_2.3.0      ggthemes_4.2.0     ggmap_3.0.0        ggplot2_3.3.0      doParallel_1.0.15  doSNOW_1.0.18     
 [7] snow_0.4-3         iterators_1.0.12   foreach_1.4.8      stringr_1.4.0      pracma_2.2.5       spdep_1.1-3       
[13] sf_0.8-0           spData_0.3.2       gridExtra_2.3      lubridate_1.7.4    mapproj_1.2.6      maps_3.3.0        
[19] rgdal_1.4-6        RColorBrewer_1.1-2 classInt_0.4-1     raster_3.0-7       plotrix_3.7-6      maptools_0.9-8    
[25] rgeos_0.5-2        readr_1.3.1        haven_2.3.1        dplyr_0.8.3        ipumsr_0.5.1       INLA_19.09.03     
[31] sp_1.3-1           survey_3.36        survival_2.44-1.1  Matrix_1.2-17      foreign_0.8-71     readxl_1.3.1      
[37] ddpcr_1.13        

loaded via a namespace (and not attached):
 [1] nlme_3.1-140        bitops_1.0-6        gmodels_2.18.1      httr_1.4.1          tools_3.6.1         utf8_1.1.4         
 [7] R6_2.4.0            KernSmooth_2.23-15  DBI_1.0.0           colorspace_1.4-1    withr_2.1.2         tidyselect_1.1.1   
[13] compiler_3.6.1      cli_1.1.0           expm_0.999-4        scales_1.1.0        jpeg_0.1-8.1        pkgconfig_2.0.3    
[19] rlang_0.4.7         rstudioapi_0.10     gtools_3.8.1        magrittr_1.5        Rcpp_1.0.2          munsell_0.5.0      
[25] fansi_0.4.0         lifecycle_0.2.0     stringi_1.4.3       yaml_2.2.1          MASS_7.3-51.4       plyr_1.8.6         
[31] gdata_2.18.0        forcats_0.4.0       crayon_1.3.4        deldir_0.1-23       lattice_0.20-38     splines_3.6.1      
[37] hms_0.5.1           zeallot_0.1.0       pillar_1.4.2        boot_1.3-22         rjson_0.2.20        codetools_0.2-16   
[43] LearnBayes_2.15.1   glue_1.3.1          mitools_2.4         vctrs_0.3.2         png_0.1-7           RgoogleMaps_1.4.5.3
[49] cellranger_1.1.0    gtable_0.3.0        purrr_0.3.2         tidyr_1.0.2         assertthat_0.2.1    e1071_1.7-2        
[55] coda_0.19-3         class_7.3-15        tibble_2.1.3        units_0.6-5        


## Disclaimer

The code in this repository was developed by IDM to support our research in disease transmission and managing epidemics as well as family planning and maternal, neonatal, and child health. We’ve made it publicly available under the MIT License to provide others with a better understanding of our research and an opportunity to build upon it for their own work. We make no representations that the code works as intended or that we will provide support, address issues that are found, or accept pull requests. You are welcome to create your own fork and modify the code to suit your own modeling needs as contemplated under the MIT License.
