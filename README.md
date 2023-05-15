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

### Virtual Machine Setup
1. Spin up a Windows VM. Our VM currently has 32GB, 8 cores, and a 80GB drive. We will be increasing this, however, for our needs.
2. Install Git (if using a github repository). The default setup settings can be used. For this step and the following installation steps, if security settings do not allow you to install directly on the VM, you may download the standalone installer on your local laptop, copy it to the VM, and then install.
3. Install R for Windows (default setup settings are fine).
4. Install R Studio (default setup settings are fine).

### R environment Setup
1. Choose a desired location in your user directory for the repo to live. Create an "SAE" directory (i.e. 'C:\Users\jsmith\SAE), and within this directory clone or copy the "SmallAreaEstimationForSurveyIndicators" repo to that directory.
     Note: if using 'git clone', you will need to verify your git credentials via token or browser authentication.
2. If you want to switch to a remote branch on the repository, you can use the following command in Git CMD bash terminal:
     git checkout --track origin/<branch_name>
3. Copy or create a 'RawData' directory within the "SmallAreaEstimationForSurveyIndicators" directory (or in a desired location). This will contain the raw survey data that is used by the Main.R script for processing and model fitting. This directory should have the following:
     1)'DHS' folder - contains the DHS survey data, with a folder per DHS code. 
     2)'shapefiles' folder - contains shapefile data for each country being run, organized by a folder per country.
     3)'surveyCodeBook.xlsx' file - lists the DHS files that are included in this project and the corresponding stratification variables.
4. Open an R Studio session (you can use the 64-bit version)
5. Create a Project from the repo. Go to File > 'New Project' > 'Existing Directory'. Select the 'SmallAreaEstimationForSurveyIndicators' directory (the repo we just cloned)> 'Create Project'
6. Verify that the latest 'renv.lock' file is present in this directory
7. Ensure that 'SmallAreaEstimationForSurveyIndicators' is set as your current working directory, and install the package 'renv'. You can do this by typing the following command in the R console: install.packages('renv')
8. Activate renv to ensure that the project library is made active for newly launched R sessions.
     In the R console, enter the command "renv::activate()".
     Type 'y' and Enter to proceed through the initial message.
     This will then create a 'renv' directory in the working directory that tracks the environment's packages and versions.
9. Restore the required packages from the renv.lock file by entering the command "renv::restore()". This step will compare the packages and versions in the 'renv.lock' file to the packages currently installed in the library paths & consequently uses that information to retrieve and reinstall those packages in your project if needed (this may take several minutes). It will warn you that INLA cannot be installed (This is because INLA is not in the CRAN library). Type 'y' and hit enter to proceed.
10. As expected, you'll notice in the logs of the command above that one package, INLA, could not be installed. In order to install this package (and its dependencies), use the following command:
     install.packages("INLA",repos=c(getOption("repos"),INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)
11. Run the following command to install additional packages from CRAN: install.packages(c('ddpcr','readxl','survey','ipumsr','rgeos','maptools','plotrix','raster','rgdal','mapproj','lubridate','doSNOW','ggmap','ggthemes','mapdata'))

### Customizing the R Code to your environment
In order to run the Main_master.R script, you need to customize a 'env_config.R' file (located in the repo root directory) using the template provided in the SmallAreaEstimationForSurveyIndicators repo. 

The env_config.R file needs the following params to be set in order for the code to be run properly:
1. project_path - path to the project directory (containing any project function files and the 'project_config.R' file)
      e.g. "C:/Users/jsmith/SmallAreaEstimationForSurveyIndicators/Project_Examples/FP_Parity/"
      The 'project_config.R' file may need to be updated to indicate the countries the script is being run against (i.e. "ALL", "Benin", c("Benin","Cameroon"), etc)
2. SAEDir - full path to the directory where Main.R is located
      e.g. "C:/Users/jsmith/SAE/SmallAreaEstimationForSurveyIndicators/"
3. RawDataDir - full path to where the 'RawData' directory lives. Using the setup steps above (if in the repo):
      e.g. "C:/Users/jsmith/SAE/SmallAreaEstimationForSurveyIndicators/"
4. codeRepoName - name of the code repository (directory beneath 'SAE' directory) 
      e.g. "SmallAreaEstimationForSurveyIndicators/"
5. projectResultsDir - full path of the desired location for the 'Projects' directory that stores the model results when the Main_master.R script is run
      e.g. "C:/Users/jsmith/SAE/SmallAreaEstimationForSurveyIndicators/"

You may now run the Main.R model script. Please note that in order to run this script, you must have the 'SmallAreaEstimationForSurveyIndicators' repo set as your working directory. Several test project configurations are available for your reference in this repo under the 'Project_Examples' directory. To use each, you may set the 'project_path' variable in env_config.R to the respective project directory.

## Environment

The following is the current environment I'm using to run the framework. I plan to develop a docker and conda environment for the framework in the future.  

R version 4.2.2
Platform: x86_64-w64-mingw32/x64 (64-bit) 
Running under: Windows 10 x64

To see a complete list of the packages and their respective versions used, you may reference the renv.lock file in this directory.


## Disclaimer

The code in this repository was developed by IDM to support our research in disease transmission and managing epidemics as well as family planning and maternal, neonatal, and child health. We’ve made it publicly available under the MIT License to provide others with a better understanding of our research and an opportunity to build upon it for their own work. We make no representations that the code works as intended or that we will provide support, address issues that are found, or accept pull requests. You are welcome to create your own fork and modify the code to suit your own modeling needs as contemplated under the MIT License.
