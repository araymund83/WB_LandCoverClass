if (!require("Require")) {
  install.packages("Require")
  library(Require)
}

Require("PredictiveEcology/SpaDES.install")
installSpaDES()

studyarea <- "WB"

source("01_init.R")
source("02_paths.R")
source("03_packages.R")
source("04_options.R")
source("05_preamble.R")
source("06_generateSpeciesLayers.R")
source("07_borealDataPrep.R")
#source("08_mainSim.R")
