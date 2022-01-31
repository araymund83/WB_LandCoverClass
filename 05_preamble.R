do.call(SpaDES.core::setPaths, paths1)

preambleObjects <- list()
preambleParams <- list(
  WBI_preamble = list(
    'studyArea' = "BC",
    'bcr' = "bcr6",
    'studyAreaName' = studyAreaName
  )
)

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

