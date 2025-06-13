

# INITIALIZE RENV FRAMEWORK
renv::init()

# CHECK TO SEE IF ALL PACKAGES RECORDED
renv::status()
?renv::status()

# INSTALL INLA FROM INLA REPO
install.packages('INLA',repos=c(getOption('repos'),INLA='https://inla.r-inla-download.org/R/stable'), dep=TRUE)

# INSTALL ADDITIONAL LIBRARIES
renv::install("data.table")

renv::status()

# UPDATE LOCKFILE
renv::snapshot()

# RESTORE LIBRARIES FROM LOCK FILE
renv::restore()

# CHECK LIBPATHS
.libPaths()

