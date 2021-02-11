#--------------------------------------------
## Set paths for each part of the simulation
#--------------------------------------------
## studyAreas
paths1 <- list(
  ## use same cachePath for all data-prep steps before dynamic simulation
  #cachePath = file.path("cache", studyarea,"dataPrepGIS", "preamble"),
  cachePath = file.path("cache", "dataPrepGIS", "preamble"),
  modulePath = "modules", 
  inputPath = "inputs/studyArea/data",
  outputPath = file.path("outputs")
)

## species layers
paths2 <- list(
  ## use same cachePath for all data-prep steps before dynamic simulation
  # cachePath = file.path("cache",studyarea, "dataPrepGIS","speciesLayers"),
  cachePath = file.path("cache", "dataPrepGIS","speciesLayers"),
  modulePath = c(file.path(getwd(), "modules"),
                 file.path(getwd(), "modules/scfm/modules")),
  inputPath = "inputs",
  outputPath = file.path("outputs")
)

## boreal data prep
paths2a <- list(
  #cachePath = file.path("cache", studyarea,"dataPrepGIS", "borealDataPrep"),
  cachePath = file.path("cache","dataPrepGIS", "borealDataPrep"),
  modulePath = "modules",
  inputPath = "inputs",
  outputPath =file.path("outputs")
)

## main simulation 
paths3 <- list(
  #use a separate cachePath for each dynamic simulation
  cachePath = file.path("cache"),
  modulePath = c(file.path(getwd(), "modules"),
                 file.path(getwd(), "modules/scfm/modules")),
  inputPath = "inputs",
  outputPath = checkPath(file.path("outputs/results"), 
                         create = TRUE)
)