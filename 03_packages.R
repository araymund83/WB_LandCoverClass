## TODO: are all of these actually used?
pkgs <- c(
  #"PredictiveEcology/reproducible@e8e1a726c3ae6ceae9233dc51195d5e51d1c7211", ## TODO: remove?
  "PredictiveEcology/reproducible@development",
  "PredictiveEcology/SpaDES.core@development",
  "PredictiveEcology/SpaDES.tools@development",
  "PredictiveEcology/LandR@development", # @6a291baed19dab2acee3bbcb7e182c79ae8bfbdd
  "achubaty/amc@development",
  "PredictiveEcology/pemisc@development",
  "PredictiveEcology/map@development",
  "PredictiveEcology/SpaDES.experiment@development",
  "PredictiveEcology/quickPlot@development",
  "PredictiveEcology/fireSenseUtils@development",
  "ianmseddy/LandR.CS",
  "PredictiveEcology/usefulFuns",
  
  ## TODO: most of these get pulled in as dependencies already; cleanup
  "bookdown",
  "data.table",
  "dplyr",
  "fasterize",
  "future",
  "ggplot2",
  "googledrive (>= 1.0.1)",
  "gridExtra",
  "magrittr",
  "mgcv",
  "nlme",
  "plyr",
  "raster",
  "RColorBrewer",
  "scam (== 1.2.3)",
  "sf", 
  "sp",
  "tinytex"
)

Require(pkgs, require = FALSE) ## TODO: check which do need to be loaded

## don't need to load packages for modules; done automatically but ensure they are installed.
makeSureAllPackagesInstalled(paths2$modulePath)
