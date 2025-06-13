# File name: Dockerfile
FROM rocker/rstudio:latest

# INSTALL DEPENDENCIES
RUN sudo apt-get update -y && sudo apt-get install -y \
    libxml2-dev \
    libxml2-utils \
    libpng-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libmysqlclient-dev \
    libmysqlclient21 \
    libcurl4-openssl-dev \
    libssl-dev \
    curl \
    sed \
    grep \
    bash

RUN \
R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))" \
R -e "install.packages('pacman', dependencies = TRUE, repos = c(CRAN = 'https://cloud.r-project.org'))" \
R -e "install.packages('INLA',repos=c(getOption('repos'),INLA='https://inla.r-inla-download.org/R/stable'), dep=TRUE)"

WORKDIR /home/rstudio/project

COPY renv.lock renv.lock
COPY renv/activate.R renv/activate.R
COPY .Rprofile .Rprofile

COPY SmallAreaEstimationForSurveyIndicators.Rproj SmallAreaEstimationForSurveyIndicators.Rproj
COPY env_config.R env_config.R
COPY Main.R Main.R
COPY Config_paths.R Config_paths.R
COPY Config_project.R Config_project.R

COPY General_utils General_utils
COPY Project_Examples Project_Examples


RUN chown -R rstudio . \
 && sudo -u rstudio R -e 'source("renv/activate.R"); renv::restore()'

#RUN mkdir -p renv
#COPY renv.lock renv.lock
#COPY .Rprofile .Rprofile
#COPY renv/activate.R renv/activate.R
#COPY renv/settings.json renv/settings.json

#RUN mkdir renv/.cache
#ENV RENV_PATHS_CACHE=renv/.cache

#COPY . .

#COPY . /home/rstudio/project
#WORKDIR /home/rstudio/project
#WORKDIR /project
#COPY renv.lock renv.lock

#ENV RENV_PATHS_LIBRARY=renv/library

#RUN mkdir -p renv
#COPY .Rprofile .Rprofile
#COPY renv/activate.R renv/activate.R
#COPY renv/settings.json renv/settings.json

#RUN mkdir -p renv
#COPY renv.lock renv.lock
#COPY .Rprofile .Rprofile
#COPY renv/activate.R renv/activate.R
#COPY renv/settings.dcf renv/settings.dcf

# change default location of cache to project folder
#RUN mkdir renv/.cache
#ENV RENV_PATHS_CACHE=renv/.cache






#RUN \
#R -e "renv::restore()"

#RUN chmod -R 755 /home/rstudio/project



