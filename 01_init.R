################################################################################
## Initialization parameters and settings
################################################################################

.starttime <- Sys.time()
message("Your current temporary directory is ", tempdir())

## user- and machine-specific settings
cacheDB <- "sqlite" ## default cache backend
machine <- Sys.info()[["nodename"]]
user <- Sys.info()[["user"]]
if (user == "araymundo") {
  scratchDirRas <- reproducible::checkPath(file.path("~/scratch/WB_LandCoverClass"), create = TRUE)
  if (grepl(pattern = "spades", x = machine)) {
    system(paste0("chmod -R 777 ", scratchDirRas), wait = TRUE) ## TODO: why? also, too open
  }
  userEmail <- "araymund83@gmail.com"
} else if (user == "achubaty") {
  cacheDB <- "postgresql"
  scratchDirRas <- if (machine == "forcast03") {
    file.path("/tmp/scratch/posthocbinning")
  } else {
    file.path("/mnt/scratch/posthocbinning")
  }
  userEmail <- "achubaty@for-cast.ca"
}

## settings below generally won't need to be changed by the user
cloudFolderID <- "https://drive.google.com/drive/folders/1AuEcaGDQ20_QtLgTNEHAxXlT_q_rzMsS?usp=sharing"
eventCaching <- c(".inputObjects", "init")
fireEpoch <- c(1970, 2019)
forestedLCCClasses <- c(1:15, 20, 32, 34:36)
treeClassesToReplace <- c(34:35)
#forestedLCCClasses <- c(1:15, 34:36)
#forestedLCCClasses10 <- c(1,2,5,6,8,10,11,17)
#forestedLCCClasses10 <- c(1:6,14,17)
LCCClassesToReplaceNN <- c(34:36)
rasterMaxMemory <- 5e+12
simTimes <- list(start = 0, end = 100)
successionTimestep <- 10  # for dispersal and age reclass.
useParallel <- TRUE
vegLeadingProportion <- 0.8 # indicates what proportion the stand must be in one species group for it to be leading.
## TODO: why is vegLeadingProportion zero?!

