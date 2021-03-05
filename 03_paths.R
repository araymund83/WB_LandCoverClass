paths <- list(
              inputPath = checkPath(file.path(getwd(),"inputs"), create = TRUE),
              modulePath = c(file.path(getwd(),'modules'),
                             file.path(getwd(), "modules/scfm/modules")),
              cachePath = checkPath(file.path(getwd(),"cache"), create = TRUE),
              outputPath = file.path(getwd(), 'outputs')
)

inputsCache <- checkPath(file.path(paths$cachePath, "inputs", studyarea), create = TRUE)
preambleCache <- checkPath(file.path(paths$cachePath, "preamble", studyarea), create = TRUE)   
simulationsCache <- checkPath(file.path(paths$cachePath, "sims", studyarea), create = TRUE)

SpaDES.core::setPaths(modulePath = paths$modulePath, 
                      inputPath = paths$inputPath, 
                      outputPath = paths$outputPath, 
                      cachePath = inputsCache)
