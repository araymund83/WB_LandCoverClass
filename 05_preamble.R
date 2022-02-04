do.call(SpaDES.core::setPaths, paths1)

preambleObjects <- list()
preambleParams <- list(
  WBI_preamble = list(
    'studyArea' = "BC",
    'bcr' = "bcr6",
    'studyAreaName' = studyAreaName
  )
)

mySim <- simInit(params = preambleParams, modules = "WBI_preamble",
                 objects = preambleObjects)

mySimOut <- spades(mySim)


simOutPreamble <- Cache(simInitAndSpades,
                        times = list(start = 0, end = 1),
                        params = preambleParams,
                        modules = c("WBI_preamble"),
                        objects = preambleObjects,
                        paths = paths1,
                        userTags = c('WBI_preamble', studyAreaName)
)

dataPrepFile <- file.path(Paths$inputPath, paste0("simOutPreamble_", studyAreaName,".qs"))
saveSimList(simOutPreamble, dataPrepFile)
loadSimList('simOutPreamble_BC.qs', paths = paths1$inputPath)

simOutPreamble<- qs::qread('./inputs/studyArea/simOutPreamble_BC.qs')
