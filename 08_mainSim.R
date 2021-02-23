################################################################################
## main simulation
################################################################################

do.call(SpaDES.core::setPaths, paths3) # Set them here so that we don't have to specify at each call to Cache

simTimes <- list(start = 0, end = 100)

modulesLandR <- list("Biomass_core")

modulesFire <- c("scfmLandcoverInit", 
                 "scfmRegime",
                 "scfmDriver",
                 "scfmIgnition",
                 "scfmEscape",
                 "scfmSpread")

moduleRegeneration <- ("Biomass_regeneration")

allModules <- c(modulesLandR,
                modulesFire,
                moduleRegeneration
)

#### Setting Parameters ----------------------------------------
paraSim <- list(
  
  # Biomass_borealDataPrep = list(
  #   "subsetDataBiomassModel" = TRUE,
  #   "subsetDataAgeModel" = TRUE
  # ),
  Biomass_core = list(
    ".plotInitialTime" = NA
    , ".saveInitialTime" = NA
    , ".useCache" = c(".inputObjects", "init")
    , "seedingAlgorithm" = "wardDispersal"
    , ".plotInterval" = 10
    , ".useCache" = "init"
    , "successionTimestep" = successionTimestep
    , "initialBiomassSource" = "cohortData" 
    , "sppEquivCol" = sppEquivCol
    , "sppColors" = sppColorVect
    , "plotOverstory" = TRUE
    , "growthAndMortalityDrivers" = "LandR"
    , "vegLeadingProportion" = 0
    , ".plotMaps" = TRUE
    
  ),
  scfmLandcoverInit = list(
    ".plotInitialTime" = NA
    #"fireRegimePolys" = simOutPreamble$fireRegimePolygons,
    #"sliverThreshold" = 1e10,
    #"flammableMap" = simOutPreamble$flammabilityMap,
    #"vegMap" = simOutPreamble$vegMap
  ),
  scfmSpread = list(
    "pSpread" = 0.235,
    "returnInterval" = 1,
    "startTime" = simTimes$start,
    ".plotInitialTime" = NA,
    ".plotInterval" = NA,
    ".saveInitialTime" = NA,
    ".saveInterval" = 1
  ),
  scfmDriver = list(
    #"targetN" = 1000,
    "studyArea" = studyArea,
    "fireRegimeRas" = simOutSppLayers$fireRegimeRas,
    "fireRegimePolys" = simOutSppLayers$fireRegimePolys,
    "scfmRegimePars" = simOutSppLayers$scfmRegimePars,
    "landscapeAttr" = simOutSppLayers$landscapeAttr,
    "flammableMap" = simOutSppLayers$flammableMap,
    ".useParallel" = FALSE,
    "quickCalibration" = FALSE # <~~~~~~~ Should only be used for DEVELOPMENT, not PRODUCTION!
  ),
  scfmRegime = list(
    fireCause = "L",
    #"targetBurnRate" = 1/65,
    "fireEpoch" = fireEpoch
  ),
  
  scfmIgnition = list(
    "returnInterval" = 1
  ),
  scfmEscape = list(
    "returnInterval" = 1
  ),
  # scfmSpread = list(
  #   "pSpread" = 0.235,
  #   "returnInterval" = 1,
  #   "startTime" = simTimes$start,
  #   ".plotInitialTime" = 1,
  #   ".plotInterval" = successionTimestep,
  #   ".saveInitialTime" = NA,
  #   ".saveInterval" = 1
  # ),  
  Biomass_regeneration = list(
    "fireTimestep" = 1
    , "fireInitialTime" = simTimes$start + 1
    , "successionTimestep" = successionTimestep
    , ".useCache" = c(".inputObjects", "init")
  )
)

simObjects <- list(
  "studyArea" = studyArea#always provide a SA
  ,"rasterToMatchLarge" = rasterToMatchLarge  #always provide a RTM
  ,"rasterToMatch" = rasterToMatch
  ,"studyAreaLarge" = studyAreaLarge
  #,"studyAreaReporting" = simOutPreamble[["studyAreaReporting"]]
  #,"rasterToMatchReporting" = simOutPreamble[["rasterToMatchReporting"]]
  ,"sppEquiv" = sppEquivalencies_CA
  ,"sppEquivCol" = sppEquivCol
  ,"sppColorVect" = sppColorVect
  #,"vegMap" = simOutPreamble$vegMap
  #,"flammableMap" = simOutPreamble$flammabilityMap
  #,"fireRegimePolys" = simOutPreamble$fireRegimePolygons
  #,"standAgeMap" = simOutPreamble$standAgeMap2011
  ,"omitNonVegPixels" = TRUE
  ,"biomassMap" = simOutSppLayers[["biomassMap"]]
  ,"cohortData" = simOutSppLayers[["cohortData"]]
  ,"ecoDistrict" = simOutSppLayers[["ecodistrict"]]
  ,"ecoregion" = simOutSppLayers[["ecoregion"]]
  ,"ecoregionMap" = simOutSppLayers[["ecoregionMap"]]
  ,"pixelGroupMap" = simOutSppLayers[["pixelGroupMap"]]
  ,"minRelativeB" = simOutSppLayers[["minRelativeB"]]
  ,"species" = simOutSppLayers[["species"]]
  ,"speciesLayers" = simOutSppLayers[["speciesLayers"]]
  ,"speciesEcoregion" = simOutSppLayers[["speciesEcoregion"]]
  ,"sufficientLight" = simOutSppLayers[["sufficientLight"]]
  ,"rawBiomassMap" = simOutSppLayers[["rawBiomassMap"]]
  , "cloudFolderID" = cloudFolderID
)
succTS <- c(seq(simTimes$start, simTimes$end,
                by = paraSim$Biomass_core$successionTimestep), simTimes$end)
outputsLandR <- data.frame(
    objectName = rep(c ("cohortData",
                        "burnMap",
                        "simulationOutput",
                        "pixelGroupMap",
                        "simulatedBiomassMap",
                        "ANPPMap",
                        "mortalityMap",
                        "burnSummary",
                        "flammableMap",
                        "summaryBySpecies",
                        "rstCurrentBurn",
                        "vegTypeMap",
                        "burnDT",
                        "speciesTable"), each = length(succTS)),
   saveTime = c(rep(succTS, times = 8))
)

simOutputs <- data.frame(objectName = objs,
                         saveTime = rep(seq(0, 1000,50), each = length(objs)),
                         eventPriority = 1,
                         stringAsFactors = FALSE)

simOutputs <- rbind(simOutputs, data.frame(objectName = c('summarySubCohortData', 
                                                          'summaryBySpecies'), 
                                           saveTime = times$end, eventPriority = 1))

simOutputs <- rbind(simOutputs, data.frame(objectName = 'simulationOutput', 
                                           saveTime = times$end, eventPriority = 1))





clearPlot()
#set.seed(3456)
# LandRTestRIABig2 <- Cache(simInit,
#                           times = simTimes
#                           ,params = paramSim
#                           ,modules = allModules
#                           ,objects = simObjects
#                           ,outputs = simOutputs
#                           ,paths = simPaths
#                           ,loadOrder = unlist(allModules)
#                           ,cacheRepo = simPaths$cachePath
#                           ,cacheTags = c("RIATest))

mySimOut <- simInitAndSpades(times = simTimes
                             ,params = paraSim
                             ,modules = allModules
                             ,objects = simObjects
                             ,outputs = simOutputs
                             ,paths = paths3
                             ,loadOrder = unlist(allModules), debug = 1)
