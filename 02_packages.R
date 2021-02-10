################################################################################
##Load packages for global.R
### don't need to load packages for modules. It is done automatically but 
### ensure they are installed
################################################################################

library("devtools")
if (FALSE){
  devtools::install_github("PredictiveEcology/reproducible@development")
  devtools::install_github("PredictiveEcology/reproducible", ref = "e8e1a726c3ae6ceae9233dc51195d5e51d1c7211")
  devtools::install_github("PredictiveEcology/LandR@development") #, ref = "6a291baed19dab2acee3bbcb7e182c79ae8bfbdd")
  devtools::install_github("PredictiveEcology/usefulFuns")
  devtools::install_github("achubaty/amc@development")
  devtools::install_github("PredictiveEcology/pemisc@development")
  devtools::install_github("PredictiveEcology/map@development")
  devtools::install_github("PredictiveEcology/SpaDES.core@development")
  devtools::install_github("PredictiveEcology/SpaDES.tools@development")
  devtools::install_github("PredictiveEcology/SpaDES.experiment", dependencies = TRUE)
  devtools::install_github("PredictiveEcology/quickPlot@development", upgrade = "always")
  #devtools::install_github("PredictiveEcology/fireSenseUtils")
  devtools::install_github("ianmseddy/LandR.CS", dependencies = TRUE)
}
library("Require")
Require("reproducible")
Require("SpaDES")
Require("SpaDES.core")
Require("SpaDES.experiment")
Require("LandR")
Require("raster")
Require("plyr"); Require("dplyr")
Require("usefulFuns")
Require("data.table")
Require("amc")
Require("sf")
Require("magrittr")
Require("fasterize")
Require("nlme")
Require("future")
Require("mgcv")
Require("scam(== 1.2.3)")
Require("ggplot2")
Require("gridExtra")
Require("RColorBrewer")
Require("tinytex")
Require("citr")
Require("bookdown")

