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
