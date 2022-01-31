#--------------------------------------------
## Set paths for each part of the simulation
#--------------------------------------------

## scratch directory for raster operations (see 01-init.R)
message("The 'raster' package is using ", scratchDirRas, " as scratch directory.")

## studyAreas
paths1 <- list(
  ## use same cachePath for all data-prep steps before dynamic simulation
  cachePath = file.path("cache", "dataPrepGIS", "preamble"),
  modulePath = "modules",
  inputPath = file.path("inputs", studyarea),
  outputPath = file.path("outputs")
)

## species layers
paths2 <- list(
  ## use same cachePath for all data-prep steps before dynamic simulation
  cachePath = file.path("cache",studyarea, "dataPrepGIS","speciesLayers"),
  #cachePath = file.path("cache"),
  modulePath = c("modules", "modules/scfm/modules"),
  inputPath = "inputs",
  outputPath = file.path("outputs")
)

## boreal data prep
paths2a <- list(
  cachePath = file.path("cache", studyarea, "dataPrepGIS", "borealDataPrep"),
  modulePath = "modules",
  inputPath = "inputs",
  outputPath = file.path("outputs")
)

## main simulation
paths3 <- list(
  #use a separate cachePath for each dynamic simulation
  cachePath = file.path("cache"),
  modulePath = c("modules", "modules/scfm/modules"),
  inputPath = "inputs",
  outputPath = reproducible::checkPath(file.path("outputs/results"),  create = TRUE)
)

