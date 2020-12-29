################################################################################
## Initialization parameters and settings
################################################################################

.starttime <- Sys.time()

stopifnot(utils::packageVersion("googledrive") == "1.0.1")
#googledrive::drive_auth(use_oob = TRUE)
googledrive::drive_auth(email = "araymund83@gmail.com")

#### for BorealCloud -------------------------------------------------------------

workDirectory <- getwd()
message("Your current temporary directory is ", tempdir())
# Raster tmp
scratchDirRas <- file.path("~/scratch/WB_LandCoverClass" )
if(dir.create(scratchDirRas)) system(paste0("chmod -R 777 ", scratchDirRas), wait = TRUE) 
raster::rasterOptions(default = TRUE)
maxMemory <- 5e+12
options(rasterMaxMemory = maxMemory, rasterTmpDir = scratchDirRas)

activeDir <- if (dir.exists(scratchDirRas)) {
  file.path("~/GITHUB/WB_LandCoverClass")
}

#### Load libraries ------------------------------------------------------------

library("reproducible")
library("SpaDES.core")
library("SpaDES.experiment")
library("raster")
library("usefulFuns")
library("LandR")
library("data.table")
library("sf")
library("magrittr")
library("fasterize")
library("ggplot2")
library("gridExtra")

#### setting paths --------------------------------------------------------------
setPaths(cachePath = file.path(getwd(), "cache"),
         inputPath = checkPath(file.path(getwd(), "inputs"),create = TRUE),
         modulePath = file.path(getwd(), "modules"),
         outputPath = checkPath(file.path(getwd(), "outputs"),
                                     create = TRUE))

