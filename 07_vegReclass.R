do.call(SpaDES.core::setPaths, paths2)

simObjects <- list(
  'cohortData' = outSimSppLayers$cohortData,
  'pixelGroupMap' = outSimSppLayers$pixelGroupMap,
  'sppEquiv' = outSimSppLayers$sppEquiv,
  'sppEquivCol' =  "WB"#outSimSppLayers$sppEquivCol
)
simParams <- list(
  WBI_vegReclass = list(
    'studyAreaName' = "bcr6ABBC" #TODO: should be studyAreaName ABBC for testing purposes

  )
)

vegReclass <- Cache(simInitAndSpades,
                        times = list(start = 0, end = 1),
                        params = simParams,
                        modules = c("WBI_vegReclass"),
                        objects = simObjects,
                        paths = paths2, ## TODO: I am not sure where it should be stored.
                        userTags = c('WBI_vegReclass', studyAreaName)
)

dataPrepFile <- file.path(Paths$inputPath, paste0("vegReclass_", studyAreaName,".qs"))
saveSimList(simOutPreamble, dataPrepFile)
