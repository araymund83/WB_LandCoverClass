do.call(SpaDES.core::setPaths, paths2)

objects2 <- list(
  #"nonTreePixels" = simOutPreamble$nonTreePixels,
  "omitNonVegPixels" = TRUE,
  #"cloudFolderID" = cloudFolderID,
  "rasterToMatch" = rasterToMatch,
  "rasterToMatchLarge" = rasterToMatchLarge,
  "sppColorVect" = sppColorVect,
  "sppEquiv" = sppEquiv,
 # "speciesLayers" = speciesLayers2001,
  "studyArea" = studyArea,
  "studyAreaLarge" = studyAreaLarge,
  #"studyAreaReporting" = simOutPreamble$studyAreaReporting,
  "rstLCC " = rstLCC,
  "vegMap" = vegMap,
  "firePoints" = firePoints,
  "standAgeMap" = standAgeMap2011,
  "rawBiomassMap" = rawbiomassMap2001,
  "flammableMap" = flammableMap,
  "ecoregions" = ecoregionsMap
)

parameters2 <- list(
 Biomass_speciesData = list(
      "sppEquivCol" = sppEquivCol,
      "types" = "KNN"
  ),
 Biomass_borealDataPrep = list(
    "sppEquivCol" = sppEquivCol,
    "speciesUpdateFunction" = list(
      quote(LandR::speciesTableUpdate(sim$species, sim$speciesTable,
                                       sim$sppEquiv, P(sim)$sppEquivCol)),
      quote(LandR::updateSpeciesTable(sim$species, sim$speciesParams))
     ) ## ### MAKE SURE of closing the list in the right plaCE!!!!!!!
     , "biomassModel" = quote(lme4::lmer(B ~ logAge * speciesCode + cover * speciesCode +
                                           (logAge + cover | ecoregionGroup)))
     , "forestedLCCClasses" =  forestedLCCClasses
     , "LCCClassesToReplaceNN" = LCCClassesToReplaceNN
     , "pixelGroupAgeClass" = dataPrep$pixelGroupAgeClass
     #, ".useCache" = c(".inputObjects", "init")
#     #, "runName" = runName
     ,"standAgeMap" = standAgeMap2011
     , "rstLCC" = rstLCC
     , "rawBiomassMap" = rawbiomassMap2001
#     , "speciesLayers" = speciesLayers2001
     , "successionTimestep" = 10
     , "subsetDataBiomassModel" = 10
     #, "useCloudCacheForStats" = TRUE
     , ".useCache" = c(".inputObjects", "init")
     , "exportModels" = "all"
     , "pixelGroupAgeClass" = 10
   ))

dataPrepOutputs2001 <- data.frame(objectName = c("cohortData",
                                                 "pixelGroupMap",
                                                 "speciesLayers",
                                                 "standAgeMap",
                                                 "rawBiomassMap"),
                                  saveTime = 2001,
                                  file = c("cohortData2001_ABBC.rds",
                                           "pixelGroupMap2001_ABBC.rds",
                                           "speciesLayers2001_ABBC.rds",
                                           "standAgeMap2001_borealDataPrep.rds",
                                           "rawBiomassMap2001_borealDataPrep.rds"))

sppLayersFile <- file.path(Paths$outputPath, paste0("simOutSpeciesLayers_",
                                                   studyarea, ".qs"))

speciesModules <- c("Biomass_speciesData", "Biomass_borealDataPrep")

simOutSppLayers <- Cache(simInitAndSpades,
                         times = list(start = simTimes$start, end = simTimes$start + 1)
                         , params = parameters2
                         , modules = speciesModules
                         , objects = objects2
                         , outputs = dataPrepOutputs2001
                         , paths = getPaths()
                         , debug = TRUE
                         , .plotInitialTime = NA
                         , loadOrder = unlist(speciesModules)
)
saveSimList(simOutSppLayers, sppLayersFile)
outSimSppLayers <- qs::qread((file.path(Paths$inputPath, "simOutSpeciesLayers_ABBC.qs")))
