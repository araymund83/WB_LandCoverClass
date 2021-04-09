do.call(SpaDES.core::setPaths, paths2)
dataPrep <- list(
  subsetDataBiomassModel = 50,
  pixelGroupAgeClass = 20,
  successionTimeStep = 10,
  useCache = TRUE
)

dataPrepParams2001 <- list(
  Biomass_borealDataPrep = list(
    "biomassModel" = quote(lme4::lmer(B ~ logAge * speciesCode + cover * speciesCode +
                                        (logAge + cover | ecoregionGroup)))
    , "forestedLCCClasses" =  forestedLCCClasses
    , "exportModels" = "all"
    , "LCCClassesToReplaceNN" = LCCClassesToReplaceNN
    , "pixelGroupAgeClass" = dataPrep$pixelGroupAgeClass
    , "speciesUpdateFunction" = list(
      quote(LandR::speciesTableUpdate(sim$species, sim$speciesTable,
                                      sim$sppEquiv, P(sim)$sppEquivCol)),
      quote(LandR::updateSpeciesTable(sim$species, sim$speciesParams))
    )
    , "sppEquivCol" = simOutPreamble$sppEquivCol
    , "subsetDataBiomassModel" = dataPrep$subsetDataBiomassModel
    , "successionTimestep" = 10
    , "subsetDataBiomassModel" = dataPrep$subsetDataBiomassModel
    , ".useCache" = c(".inputObjects", "init")
   ),
  Biomass_speciesData = list(
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    ".studyAreaName" = paste0(studyAreaName, 2001)
  )
)

dataPrepOutputs2001 <- data.frame(
  objectName = c("cohortData",
                 "pixelGroupMap",
                 "speciesLayers",
                 "standAgeMap",
                 "rawBiomassMap"),
  saveTime = 2001,
  file = paste0 (studyAreaName, "_",
                 c("cohortData2001.rds",
                   "pixelGroupMap2001.rds",
                   "speciesLayers2001.rds",
                   "standAgeMap2001.rds",
                   "rawBiomassMap2001.rds"))
)

dataPrepObjects <- list(
  "rasterToMatch" = simOutPreamble$rasterToMatch,
  "rasterToMatchLarge" = simOutPreamble$rasterToMatchLarge,
  "sppColorVect" = simOutPreamble$sppColorVect,
  "sppEquiv" = simOutPreamble$sppEquiv,
  "studyAreaReporting" = simOutPreamble$studyAreaReporting,
  "studyArea" = simOutPreamble$studyArea,
  "studyAreaLarge" = simOutPreamble$studyAreaLarge,
  "rstLCC " = simOutPreamble$rstLCC,
  "vegMap" = simOutPreamble$vegMap,
  #"firePoints" = simOutPreamble$firePoints,
  "standAgeMap" = simOutPreamble$standAgeMap2011,
  "rawBiomassMap" = simOutPreamble$rawbiomassMap2001,
  "flammableMap" = simOutPreamble$flammableMap,
  "ecoregions" = simOutPreamble$ecoregionsMap
)

sppLayersFile <- file.path(Paths$outputPath, paste0("biomassMaps2001_",
                                                    studyAreaName, ".qs"))

biomassMaps2001 <- reproducible::Cache(simInitAndSpades,
                         times = list(start = 2001, end = 2001)
                         , params = dataPrepParams20Biomass_speciesData01
                         , modules = list( "", "Biomass_borealDataPrep")
                         , objects = dataPrepObjects
                         , outputs = dataPrepOutputs2001
                         , paths = getPaths()
                         , loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep")
                         , debug = TRUE
                         , .plots = NA
                         , userTags = c("dataPrep2001", "studyAreaName")
)
saveSimList(sim = biomassMaps2001, filename= sppLayersFile)
#biomassMaps2001 <- loadSimList("/home/araymundo/GITHUB/WB_LandCoverClass/outputs/biomassMaps2001_bcr6AB.qs")

