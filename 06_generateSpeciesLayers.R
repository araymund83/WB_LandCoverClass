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
    , "sppEquivCol" = sppEquivCol
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
                 c("cohortData2001_NWT.rds",
                   "pixelGroupMap2001_NWT.rds",
                   "speciesLayers2001_NWT.rds",
                   "standAgeMap2001_NWT_borealDataPrep.rds",
                   "rawBiomassMap2001_NWT_borealDataPrep.rds"))
)

dataPrepObjects <- list(
  "rasterToMatch" = simOutPreamble$rasterToMatch,
  "rasterToMatchLarge" = simOutPreamble$rasterToMatchLarge,
  "sppColorVect" = simOutPreamble$sppColorVect,
  "sppEquiv" = simOutPreamble$sppEquiv,
  "studyArea" = simOutPreamble$studyArea,
  "studyAreaLarge" = simOutPreamble$studyAreaLarge,
  "rstLCC " = rstLCC,
  "vegMap" = simOutPreamble$vegMap,
  "firePoints" = simOutPreamble$firePoints,
  "standAgeMap" = simOutPreamble$standAgeMap2011,
  "rawBiomassMap" = simOutPreamble$rawbiomassMap2001,
  "flammableMap" = simOutPreamble$flammableMap,
  "ecoregions" = simOutPreamble$ecoregionsMap
)

sppLayersFile <- file.path(Paths$outputPath, paste0("biomassMaps2001_",
                                                    studyAreaName, ".qs"))

biomassMaps2001 <- reproducible::Cache(simInitAndSpades,
                         times = list(start = 2001, end = 2001)
                         , params = dataPrepParams2001
                         , modules = list( "Biomass_speciesData", "Biomass_borealDataPrep")
                         , objects = dataPrepObjects
                         , outputs = dataPrepOutputs2001
                         , paths = getPaths()
                         , loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep")
                         , debug = TRUE
                         , .plots = NA
                         , userTags = c("dataPrep2001", "studyAreaName")
)
saveSimList(sim = biomassMaps2001, filename= sppLayersFile)
