################################################################################
## species layers
################################################################################

## this script makes a pre-simulation object that makes species layers
## by running Biomass_speciesData. This is the longest module to run and,
## unless the study area or the species needed change, it whould only
## be run once (even if other things change, like the simulation rep,
## or other modules). That's why caching is kept separate from the rest
## of the simulation

#do.call(SpaDES.core::setPaths, paths1)
SpaDES.core::setPaths(cachePath = preambleCache,
                      outputPath = Paths$inputPath)

#get sppEquivalencies





objects2 <- list(
  #"nonTreePixels" = simOutPreamble$nonTreePixels,
  "omitNonVegPixels" = TRUE,
  #"cloudFolderID" = cloudFolderID,
  "rasterToMatch" = rasterToMatch,
  "rasterToMatchLarge" = rasterToMatchLarge,
  "sppColorVect" = sppColorVect,
  "sppEquiv" = sppEquivalencies_CA,
  "speciesLayers" = speciesLayers2001,
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
  #"sliverThreshold" = 1e10

)

parameters2 <- list(
 # "Biomass_speciesParameters" = list(
 #     "sppEquivCol" = sppEquivCol
 #     ,"GAMMiterations" = 2
 #     , useHeight = FALSE
 #     , GAMMknots = list(
 #       "Popu_tre" = 4,
 #       "Popu_bal" = 4,
 #       "Abie_bal" = 3,
 #       "Betu_pap" = 3,
 #       "Pice_gla" = 3,
 #       "Pice_mar" = 4,
 #       "Pinu_ban" = 4,
 #       "Lari_lar" = 4,
 #       "Pinu_con" = 4
 #     )
 #     ,"minimumPlotsPerGamm" = 40
 #     ,constrainGrowthCurve = list(
 #       "Popu_tre" = c(0.3, .7),
 #       "Popu_bal" = c(0.3, .7),
 #       "Abie_bal" = c(0.3, .7),
 #       "Betu_pap" = c(0.3, .7),
 #       "Pice_gla" = c(0.3, .7),
 #       "Pice_mar" = c(0.3, .7),
 #       "Pinu_ban" = c(0.3, .7),
 #       "Lari_lar" = c(0.3, .7),
 #       "Pinu_con" = c(0.3, .7)
 #     )
 #     , constrainMortalityShape = list(
 #       "Popu_tre" = c(20, 25),
 #       "Popu_bal" = c(20,25),
 #       "Abie_bal" = c(15, 25),
 #       "Betu_pap" = c(15, 20),
 #       "Pice_gla" = c(15, 25),
 #       "Pice_mar" = c(15, 25),
 #       "Pinu_ban" = c(15,25),
 #       "Lari_lar" = c(15, 20),
 #       "Pinu_con" = c(15, 25)
 #     )
 #     , quantileAgeSubset = list(
 #       "Popu_tre" = 98, # N = 1997, trying 99
 #       "Popu_bal" = 98,
 #       "Abie_bal" = 95, #N = 250 ''
 #       "Betu_pap" = 95, #N = 96
 #       "Pice_gla" = 95, #N = 1849
 #       "Pice_mar" = 95, #N = 785
 #       "Pinu_ban" = 97, # N = 3172, 99 not an improvement. Maybe 97
 #       "Lari_lar" = 95, ##need to ask IAN
 #       "Pinu_con" = 97
 #     )
 #   ),
  Biomass_speciesData = list(
      "omitNonVegPixels" = TRUE,
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
     #, ".useCache" = c(".inputObjects", "init")
#     #, "runName" = runName
     ,"standAgeMap" = standAgeMap2011
     , "rstLCC" = rstLCC
     , "rawBiomassMap" = rawbiomassMap2001
     , "speciesLayers" = speciesLayers2001
     , "successionTimestep" = 10
     , "subsetDataBiomassModel" = 10
     #, "useCloudCacheForStats" = TRUE
     , ".useCache" = c(".inputObjects", "init")
     , "exportModels" = "all"
     , "pixelGroupAgeClass" = 10
   ),
  scfmLandcoverInit = list(
     ".plotInitialTime" = NA
     #"firePoints" = firePoints
#     #"sliverThreshold" = 1e10
#
   ),
   scfmRegime = list(
     fireCause = "L",
#     #"targetBurnRate" = 1/65,
     "fireEpoch" = fireEpoch
   ),
   scfmDriver = list(
    "studyArea" = studyArea
#   #   "fireRegimeRas" = simOutSppLayers$fireRegimeRas,
#   #   "fireRegimPolys" = simOutSppLayers$fireRegimePolys,
#   #   "scfmRegimePars" = simOutSppLayers$scfmRegimePars,
#   #   "landscapeAttr" = simOutSppLayers$landscapeAttr,
#   #   "flammableMap" = simOutSppLayers$flammableMap,
#   #   ".useParallel" = FALSE,
#   #   "quickCalibration" = FALSE
#   #
    )
)

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

sppLayersFile <- file.path(paths$inputPath, paste0("simOutSpeciesLayers_", 
                                                   studyarea, ".qs"))
#speciesModules <- c("PSP_Clean", "Biomass_speciesData", "Biomass_borealDataPrep",
  #                 "Biomass_speciesParameters", "scfmLandcoverInit", "scfmRegime")
speciesModules <- c("Biomass_speciesData", "Biomass_borealDataPrep", "scfmLandcoverInit", "scfmRegime")

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

scfmDriverObjs <- list(
  'studyArea' = simOutPreamble$studyArea,
  'fireRegimeRas' = simOutSppLayers$fireRegimeRas,
  'fireRegimePolys' = simOutSppLayers$fireRegimePolys,
  'scfmRegimePars' = simOutSppLayers$scfmRegimePars,
  'landscapeAttr' = simOutSppLayers$landscapeAttr,
  'flammableMap' = simOutSppPreamble$flammabilityMap
)

scfmDriver = list(
  #"targetN" = 1000,
  ".useParallel" = FALSE,
  "quickCalibration" = FALSE # <~~~~~~~ Should only be used for DEVELOPMENT, not PRODUCTION!
)
scfmRegime = list(
  fireCause = "L",
  #"targetBurnRate" = 1/65,
  "fireEpoch" = fireEpoch
)

scfmParams <- list(
  scfmDriver = list(
    targetN = 5000
  )
)
scfmPaths <- speciesPaths
scfmPaths$cachePath <- "scfmCache"
simScfmDriver <- Cache(simInitAndSpades
                       , times = list(start = times$start, end = times$start + 1)
                       , params = scfmParams
                       , modules = 'scfmDriver'
                       , objects = scfmDriverObjs
                       , paths = scfmPaths
                       , debug = TRUE
                       , .plotInitialTime = NA
                       , loadOrder = unlist(speciesModules)
                       , userTags = "scfmDriver",
                       cacheRepo = scfmPaths$cachePath)