################################################################################
## Initialization parameters and settings
################################################################################

.starttime <- Sys.time()

stopifnot(utils::packageVersion("googledrive") == "1.0.1")
#googledrive::drive_auth(use_oob = TRUE)  ### use only for the first time 
googledrive::drive_auth(email = "araymund83@gmail.com")

#### for BorealCloud -------------------------------------------------------------

workDirectory <- getwd()
message("Your current temporary directory is ", tempdir())
# Raster tmp
scratchDirRas <- file.path("/media/data/project/araymundo/scratch/WB_LandCoverClass")
if(dir.create(scratchDirRas)) system(paste0("chmod -R 777 ", scratchDirRas), wait = TRUE) 
raster::rasterOptions(default = TRUE)
maxMemory <- 5e+12
options(rasterMaxMemory = maxMemory, rasterTmpDir = scratchDirRas)

activeDir <- if (dir.exists(scratchDirRas)) {
  file.path(workDirectory)
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

################################################################################
##  setting options
################################################################################
options(
  "spades.recoveryMode" = 2,
  "spades.lowMemory" = TRUE,
  "reproducible.inputPaths" = NULL,
  "reproducible.cacheSaveFormat" = "qs",
  "reproducible.qsPreset" = "fast",
  "reproducible.useGDAL" = FALSE,
  "reproducible.inputPaths" = NULL,
  "reproducible.overwrite" = TRUE,
  "reproducible.useMemoise" = TRUE, # Brings cached stuff to memory during the second run
  "reproducible.useNewDigestAlgorithm" = TRUE,  # use the new less strict hashing algorithm
  "reproducible.useCache" = TRUE,
  "reproducible.cachePath" = file.path(scratchDirRas, "cache"),
  "reproducible.showSimilar" = TRUE,
  "spades.moduleCodeChecks" = FALSE, ## Turn off all module's code checking
  "spades.useRequire" = TRUE, ##asuming all pkgs are installed correctly
  "pemisc.useParallel" = TRUE
)
