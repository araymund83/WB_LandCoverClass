do.call(SpaDES.core::setPaths, paths2)
biomassMaps2011SA<- qs::qread(file.path(getwd(),"inputs", "biomassMaps2011_Bc.qs"))

simObjects <- list(
  'cohortData' = as.data.table(biomassMaps2011SA$cohortData),
  'pixelGroupMap' = biomassMaps2011SA$pixelGroupMap,
  'sppEquiv' = biomassMaps2011SA$sppEquiv,
  'sppEquivCol' =  simOutPreamble$sppEquivCol,
  'rstLCC' = simOutPreamble$rstLCC,
  'studyarea' = simOutPreamble$studyAreaReporting
)
simParams <- list(
  WBI_vegReclass = list(
    'studyArea' = simOutPreamble$studyAreaReporting, #TODO: should be studyAreaName ABBC for testing purposes
    'bcr'= "6" ## options are 4, 6, 7, 8
  )
)

mySim <- simInit(params = simParams, modules = "WBI_vegReclass",
                 objects = simObjects)

mySimOut <- spades(mySim)

# reclass <- Cache(simInitAndSpades,
#                     times = list(start = 0, end = 1),
#                     params = simParams,
#                     modules = c("WBI_vegReclass"),
#                     objects = simObjects,
#                     paths = paths2, ## TODO: I am not sure where it should be stored.
#                     userTags = c('WBI_vegReclass', studyAreaName)
# )

dataPrepFile <- file.path(Paths$inputPath, paste0("vegReclass_", studyAreaName,".qs"))
saveSimList(vegReclass, dataPrepFile)
