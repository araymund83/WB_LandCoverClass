if (!require("Require")) {
  install.packages("Require")
  library(Require)
}

Require("PredictiveEcology/SpaDES.install")
#installSpaDES() ## TODO: fix -- see SpaDES.install#7 and SpaDES.install#8

studyarea <- "MB"
bcr <- "6"
studyAreaName <- studyarea

source("01_init.R")
source("02_paths.R")
source("03_packages.R")
source("04_options.R")
source("05_preamble.R")
source("06_generateSpeciesLayers.R")
source("07_vegReclass.R")
source("07_borealDataPrep.R")
#source("08_mainSim.R")
