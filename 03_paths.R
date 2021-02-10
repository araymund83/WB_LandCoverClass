
#### setting paths --------------------------------------------------------------
setPaths(cachePath = file.path(getwd(), "cache"),
         inputPath = checkPath(file.path(getwd(), "inputs"),create = TRUE),
         modulePath = file.path(getwd(), "modules"),
         outputPath = checkPath(file.path(getwd(), "outputs"),
                                create = TRUE))

#--------------------------------------------
## Set paths for each part of the simulation
#--------------------------------------------
## studyAreas
paths1 <- list(
  ## use same cachePath for all data-prep steps before dynamic simulation
  #cachePath = file.path("cache", studyarea,"dataPrepGIS", "preamble"),
  cachePath = file.path("cache", studyarea,"dataPrepGIS", "preamble"),
  modulePath = "modules", 
  inputPath = "inputs",
  outputPath = file.path("outputs", runName)
)

## species layers
paths2 <- list(
  ## use same cachePath for all data-prep steps before dynamic simulation
  # cachePath = file.path("cache",studyarea, "dataPrepGIS","speciesLayers"),
  cachePath = file.path("cache",studyarea, "dataPrepGIS","speciesLayers"),
  modulePath = c(file.path(getwd(), "modules"),
                 file.path(getwd(), "modules/scfm/modules")),
  inputPath = "inputs",
  outputPath = file.path("outputs", runName)
)

## boreal data prep
paths2a <- list(
  #cachePath = file.path("cache", studyarea,"dataPrepGIS", "borealDataPrep"),
  cachePath = file.path("cache","dataPrepGIS", "borealDataPrep"),
  modulePath = "modules",
  inputPath = "inputs",
  outputPath =file.path("outputs", runName)
)

## main simulation 
paths3 <- list(
  #use a separate cachePath for each dynamic simulation
  cachePath = file.path("cache", runName),
  modulePath = c(file.path(getwd(), "modules"),
                 file.path(getwd(), "modules/scfm/modules")),
  inputPath = "inputs",
  outputPath = checkPath(file.path("outputs/results",runName), 
                         create = TRUE)
)