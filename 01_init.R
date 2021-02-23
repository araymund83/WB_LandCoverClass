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
#scratchDirRas <- file.path("/media/data/project/araymundo/scratch/WB_LandCoverClass")
scratchDirRas <- file.path("~/scratch")
if(dir.create(scratchDirRas)) system(paste0("chmod -R 777 ", scratchDirRas), wait = TRUE) 
raster::rasterOptions(default = TRUE)
maxMemory <- 5e+12
options(rasterMaxMemory = maxMemory, rasterTmpDir = scratchDirRas)

activeDir <- if (dir.exists(scratchDirRas)) {
  file.path(workDirectory)
}
cloudFolderID <- "https://drive.google.com/drive/folders/1AuEcaGDQ20_QtLgTNEHAxXlT_q_rzMsS?usp=sharing"

studyarea <- "RIA" ## ABBC
#studyarea <- "MBSK"

simTimes <- list(start = 0, end = 100)
sppEquivCol <- studyarea
vegLeadingProportion <- 0 # indicates what proportion the stand must be in one species group for it to be leading.
successionTimestep <- 10  # for dispersal and age reclass.
fireEpoch <- c(1970, 2019)
forestedLCCClasses <- c(1:15, 20, 32, 34:36)
#forestedLCCClasses <- c(1:15, 34:36)
#forestedLCCClasses10 <- c(1,2,5,6,8,10,11,17)
#forestedLCCClasses10 <- c(1:6,14,17)
LCCClassesToReplaceNN <- c(34:36)




